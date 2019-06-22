//
//  ScheduledController.swift
//  
//
//  Created by Ondrej Rafaj on 21/06/2019.
//

import Fluent
import SpeedsterCore


final class ScheduledController: Controller {
    
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        let scheduleManager = ScheduledManager(self.db)
        
        r.get("jobs", "scheduled") { req -> EventLoopFuture<Response> in
            // TODO: Remove Scheduled query when .alsoDecode becomes available!!!!
            return Scheduled.query(on: self.db).all().flatMap { scheduled in
                return Job.query(on: self.db)
                    .join(\Scheduled.jobId, to: \Job.id)
                    .sort(\Scheduled.requested, .ascending)
                    .all().map { jobs in
                        return jobs.map { job in
                            Scheduled.Wrapper(
                                job: job.asShort(managed: true),
                                scheduled: scheduled.first(where: { $0.jobId == job.id })?.asShort()
                            )
                        }
                }
            }
        }
        
        r.get("scheduled", ":scheduled_id") { req -> EventLoopFuture<Scheduled.Wrapper> in
            let id = req.parameters.get("scheduled_id", as: Speedster.DbIdType.self)
            return scheduleManager.scheduled(id).map { tuple in
                return Scheduled.Wrapper(
                    job: tuple.job.asShort(),
                    scheduled: tuple.scheduled.asShort()
                )
            }
        }
        
        r.post("scheduled", ":scheduled_id", "run") { req -> EventLoopFuture<Response> in
            let id = req.parameters.get("scheduled_id", as: Speedster.DbIdType.self)
            return scheduleManager.scheduled(id).flatMap { tuple in
                let buildManager = BuildManager(self.db)
                return buildManager.build(tuple).asNoContent()
            }
        }
    }
}
