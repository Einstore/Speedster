//
//  Command+Value.swift
//  
//
//  Created by Ondrej Rafaj on 04/07/2019.
//

import Foundation


extension VMRun.Command {
    
    public var value: String {
        switch self {
        case .addSharedFolder(let image, let name, let host):
            return "addSharedFolder \(image.escaped) \(name.escaped) \(host.escaped)"
        case .captureScreen(let image, let path):
            return "captureScreen \(image.escaped) \(path.escaped)"
        case .clone(let image, let destination, let clone, let snapshotName):
            let snapshot = (snapshotName?.escaped != nil) ? " \(snapshotName!.escaped)" : ""
            return "clone \(image.escaped) \(destination.escaped) \(clone.rawValue)\(snapshot)"
        case .copyFileFromGuestToHost(let image, let path, let destination):
            return "copyFileFromGuestToHost \(image.escaped) \(path.escaped) \(destination.escaped)"
        case .copyFileFromHostToGuest(let image, let path, let destination):
            return "copyFileFromHostToGuest \(image.escaped) \(path.escaped) \(destination.escaped)"
        case .createDirectoryInGuest(let image, let path):
            return "createDirectoryInGuest \(image.escaped) \(path.escaped)"
        case .deleteDirectoryInGuest(let image, let path):
            return "createDirectoryInGuest \(image.escaped) \(path.escaped)"
        case .deleteFileInGuest(let image, let path):
            return "deleteFileInGuest \(image.escaped) \(path.escaped)"
        case .deleteSnapshot(let image, let name):
            return "deleteSnapshot \(image.escaped) \(name.escaped)"
        case .fileExistsInGuest(let image, let path):
            return "fileExistsInGuest \(image.escaped) \(path.escaped)"
        case .installtools(let image):
            return "installtools \(image.escaped)"
        case .killProcessInGuest(let image, let pid):
            return "killProcessInGuest \(image.escaped) \(pid)"
        case .list:
            return "list"
        case .listDirectoryInGuest(let image, let path):
            return "listDirectoryInGuest \(image.escaped) \(path.escaped)"
        case .listProcessesInGuest(let image):
            return "listProcessesInGuest \(image.escaped)"
        case .listSnapshots(let image):
            return "listSnapshots \(image.escaped)"
        case .pause(let image):
            return "pause \(image.escaped)"
        case .readVariable(let image, let location, let variable):
            return "readVariable \(image.escaped) \(location.rawValue) \(variable)"
        case .register(let image):
            return "register \(image.escaped)"
        case .removeSharedFolder(let image, let name):
            return "removeSharedFolder \(image.escaped) \(name.escaped)"
        case .renameFileInGuest(let image, let path, let newName):
            return "renameFileInGuest \(image.escaped) \(path.escaped) \(newName.escaped)"
        case .reset(let image, let type):
            return "reset \(image.escaped) \(type.rawValue)"
        case .revertToSnapshot(let image, let name):
            return "revertToSnapshot \(image.escaped) \(name.escaped)"
        case .runProgramInGuest(let image, let flag, let program, let args):
            let args = args.map { $0.escaped }.joined(separator: " ")
            let flag = (flag != nil) ? " \(flag!.rawValue)" : ""
            return "runProgramInGuest \(image.escaped)\(flag) \(program.escaped) \(args)"
        case .runScriptInGuest(let image, let path, let script):
            return "runScriptInGuest \(image.escaped) \(path.escaped) \(script.escaped)"
        case .setSharedFolderState(let image, let name, let host, let perms):
            return "setSharedFolderState \(image.escaped) \(name.escaped) \(host) \(perms.rawValue)"
        case .snapshot(let image, let name):
            return "snapshot \(image.escaped) \(name.escaped)"
        case .start(let image, let interface):
            return "start \(image.escaped) \(interface.rawValue)"
        case .stop(let image, let type):
            return "stop \(image.escaped) \(type.rawValue)"
        case .suspend(let image, let type):
            return "suspend \(image.escaped) \(type.rawValue)"
        case .unpause(let image):
            return "unpause \(image.escaped)"
        case .unregister(let image):
            return "unregister \(image.escaped)"
        case .upgradevm(let image):
            return "upgradevm \(image.escaped)"
        case .vprobeListGlobals(let image):
            return "vprobeListGlobals \(image.escaped)"
        case .vprobeListProbes(let image):
            return "vprobeListProbes \(image.escaped)"
        case .vprobeLoad(let image, let script):
            return "aaaaaaaaa \(image.escaped) \(script.escaped)"
        case .vprobeReset(let image):
            return "vprobeReset \(image.escaped)"
        case .vprobeVersion(let image):
            return "vprobeVersion \(image.escaped)"
        case .writeVariable(let image, let location, let variable, let value):
            return "renameFileInGuest \(image.escaped) \(location.rawValue) \(variable) \(value.escaped)"
        }
    }
    
}
