import Fluent
import GitHubKit


extension Row where Model == GitHubJob {
    
    func schedule(_ commit: Commit, trigger: Root.Pipeline.Trigger, on db: Database) -> EventLoopFuture<Row<Scheduled>> {
        let scheduled = Scheduled.row()
        scheduled.jobId = self.id
        scheduled.runId = nil
        scheduled.commit = commit
        scheduled.requested = Date()
        scheduled.trigger = trigger
        return scheduled.save(on: db).flatMap { _ in
            let run = Run.row()
            run.scheduledId = scheduled.id
            run.githubjobId = self.id
            return run.save(on: db).map { _ in
                return scheduled
            }
        }
    }
    
}
