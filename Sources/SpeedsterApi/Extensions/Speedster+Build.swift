//
//  Speedster+Build.swift
//  
//
//  Created by Ondrej Rafaj on 17/06/2019.
//

import SpeedsterCore
import Fluent


extension Speedster {
    
    public static func build(job: Row<SpeedsterApi.Root>, node: Row<SpeedsterApi.Node>, db: Database) throws -> EventLoopFuture<Void> {
        return job.relatedData(on: db).flatMap { relatedData in
            return job.coreJob(from: relatedData.workflows, phases: relatedData.phases, on: db.eventLoop).flatMap { coreJob in
                let run = Run.row()
                run.jobId = job.id
                run.started = Date()
                run.speedster = coreJob
                return run.save(on: db).flatMap { _ in
                    var futures: [EventLoopFuture<Void>] = []
                    let promise = db.eventLoop.makePromise(of: Void.self)
                    let output: ExecutorOutput = { string, identifier in
                        try? Log.write(string, to: run)
                    }
                    do {
                        let executioner = try Executioner(
                            job: coreJob,
                            node: node.asCore(),
                            on: db.eventLoop,
                            output: output
                        )
                        executioner.run(finished: {
                            promise.succeed(Void())
                        }) { error in
                            promise.fail(error)
                        }
                    } catch {
                        promise.fail(error)
                    }
                    futures.append(promise.futureResult)
                    
                    func write(result: Int) -> EventLoopFuture<Void> {
                        run.finished = Date()
                        run.result = result
                        // TODO: Handle as a possible error!!!!
                        run.output = (try? Log.get(run)) ?? ""
                        try? Log.clear(run)
                        return run.save(on: db)
                    }
                    
                    return futures.flatten(on: db.eventLoop).flatMap { _ in
                        return write(result: 0)
                    }.flatMapError { error -> EventLoopFuture<Void> in
                       return write(result: -1)
                    }
                }
            }
        }
    }
    
}

