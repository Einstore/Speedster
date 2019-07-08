//
//  VMRun.swift
//  
//
//  Created by Ondrej Rafaj on 04/07/2019.
//

import Foundation
import ShellKit


public class VMRun {
    
    public enum Software {
        
        case workstation
        case fusion
        case server(host: String, port: Int = 443, login: String = "root", password: String)
        
        public var params: String {
            switch self {
            case .workstation:
                return "-T ws"
            case .fusion:
                return "-T fusion"
            case .server(host: let host, port: let port, login: let login, password: let password):
                return "-T server -h \(host) -P \(port) -u \(login) -p \(password)"
            }
        }
        
    }
    
    public enum Command {
        
        public enum PowerType: String {
            case soft
            case hard
        }
        
        public enum Interface: String {
            case gui
            case nogui
        }
        
        // MARK: Power comands
        
        /// Starts a virtual machine (.vmx file) or team (.vmtm file). The default gui option starts the machine interactively, which is required to display a VMware user interface. The nogui option suppresses the user interface, including startup dialog box, to allow noninteractive scripting.
        ///     - Important: Teams not supported on VMware Server and VMware Fusion.
        case start(image: String, interface: Interface)
        
        /// Stops a virtual machine (.vmx file) or team (.vmtm file). Use the soft parameter to power off the guest after running shutdown scripts. Use the hard parameter to power off the guest without running scripts, as if you pressed the power button. The default is to use the powerType specified in the .vmx file, if present.
        ///     - Important: Teams not supported on VMware Server and VMware Fusion.
        case stop(image: String, type: PowerType)
        
        /// Resets a virtual machine (.vmx file) or team (.vmtm file). Use the soft parameter to run shutdown scripts before rebooting the guest. Use the hard parameter to reboot the guest without running scripts, as if you pressed the reset button. The default is to use the powerType specified in the .vmx file, if present.
        ///     - Important: Teams not supported on VMware Server and VMware Fusion.
        case reset(image: String, type: PowerType)
        
        /// Suspends a virtual machine (.vmx file) or team (.vmtm) without shutting down, so local work can resume later. The soft parameter suspends the guest after running system scripts. On Windows guests, these scripts release the IP address. On Linux guests, the scripts suspend networking. The hard parameter suspends the guest without running the scripts. The default is to use the powerType specified in the .vmx file, if present.
        /// To resume virtual machine operation after suspend, use the start command. On Windows, the IP address is retrieved. On Linux, networking is restarted.
        ///     - Important: Teams not supported on VMware Server and VMware Fusion.
        case suspend(image: String, type: PowerType)
        
        /// Pauses a virtual machine (.vmx file). You can use this either to pause replay, or to pause normal operation.
        case pause(image: String)
        
        /// Resumes operation of a virtual machine (.vmx file) from where you paused replay or normal operation.
        case unpause(image: String)
        
        // MARK: Snapshot commands
        
        /// Lists all snapshots in a virtual machine (.vmx file).
        case listSnapshots(image: String)
        
        /// Creates a snapshot of a virtual machine (.vmx file). For products such as Workstation that support multiple snapshots, you must provide the snapshot name.
        /// Because the forward slash defines path names, do not use the slash character in a snapshot name, because that makes it difficult to specify the snapshot path later.
        ///     - Important: VMware Server does not support multiple snapshots
        ///     - Important: VMware Fusion does not support snapshot trees
        case snapshot(image: String, name: String)
        
        /// Removes a snapshot from a virtual machine (.vmx file). For products such as Workstation that support multiple snapshots, you must provide the snapshot name.
        /// The virtual machine must be powered off or suspended. If this snapshot has children, they become children of the deleted snapshot’s parent, and subsequent snapshots continue as before from the end of the chain.
        ///     - Important: VMware Server always deletes the root snapshot
        case deleteSnapshot(image: String, name: String)
        
        /// Sets the virtual machine to its state at snapshot time. If a snapshot has a unique name within a virtual machine, revert to that snapshot by specifying the path to the virtual machine’s configuration file and the unique snapshot name.
        /// If several snapshots have the same name, specify the snapshot by including a full path name for the snapshot. A path name is a series of snapshot names, separated by forward slash characters (/). Each name specifies a new snapshot in the tree. For example, the path name Snap1/Snap2 identifies a snapshot named Snap2 that was taken from the state of a snapshot named Snap1.
        ///     - Important: VMware Server always reverts to the root snapshot
        case revertToSnapshot(image: String, name: String)
        
        // MARK: Guest Operating System Commands
        
        public enum VariableLocation: String {
            case runtimeConfig
            case guestEnv
        }
        
        public enum Permission: String {
            case writable
            case readonly
        }
        
        public enum RunProgramFlags: String {
            case noWait = "-noWait"
            case activeWindow = "-activeWindow"
            case interactive = "-interactive"
        }
        
        /// Writes a variable into the virtual machine state or guest. You can set either runtime configuration in the .vmx file, or environment variables in the guest operating system. The latter requires VMware Tools and a valid guest login (for Linux guests, setting guestEnv requires root login).
        /// Provide the variable name and its value.
        case writeVariable(image: String, location: VariableLocation = .runtimeConfig, variable: String, value: String)
        
        /// Reads a variable from the virtual machine state or guest. You can get either runtime configuration in the .vmx file, or environment variables in the guest operating system. The latter requires a valid guest login.
        case readVariable(image: String, location: VariableLocation = .runtimeConfig, variable: String)
        
        /// Runs a program in the guest operating system.
        /// The -noWait option returns a prompt immediately after the program starts in the guest, rather than waiting for it to finish. This option is useful for interactive programs. The -activeWindow option ensures that the Windows GUI is visible, not minimized. It has no effect on Linux. The -interactive option forces interactive guest login. It is useful for Windows Vista guests to make the program visible in the console window.
        /// Provide the full path name of a program accessible to the guest. VMware Tools and valid guest login are required.
        /// Also provide full accessible path names for any files specified in the program arguments, which are optional according to requirements of the named program.
        case runProgramInGuest(image: String, flag: RunProgramFlags? = nil, program: String, args: [String] = [])
        
        /// Runs a command script in the guest operating system. VMware Tools and a valid guest login are required.
        /// The interpreter path is the command that runs the script. Provide the complete text of the script, not a filename.
        case runScriptInGuest(image: String, path: String, script: String)
        
        /// Modifies the writability state of a folder shared between the host and a guest virtual machine (.vmx file).
        /// The share name is a mount point in the guest file system. The path to folder is the exported directory on the host. A shared folder can be made writable or read‐only.
        ///     - Important: VMware Server does not support shared folders
        case setSharedFolderState(image: String, name: String, host: String, perms: Permission = .writable)
        
        /// Adds a folder to be shared between the host and guest. The share name is a mount point in the guest file system. The path to folder is the exported directory on the host.
        ///     - Important: VMware Server does not support shared folders
        case addSharedFolder(image: String, name: String, host: String)
        
        /// Removes a guest virtual machine’s access to a shared folder on the host. The share name is a mount point in the guest file system.
        ///     - Important: VMware Server does not support shared folders
        case removeSharedFolder(image: String, name: String)
        
        /// Lists all processes running in the guest operating system. VMware Tools and a valid guest login are required.
        case listProcessesInGuest(image: String)
        
        /// Stops a specified process in the guest operating system. VMware Tools and a valid guest login are required.
        /// Take process ID from the number listed after pid= in the output of listProcessesInGuest.
        case killProcessInGuest(image: String, pid: String)
        
        /// Checks whether the specified file exists in the guest operating system. VMware Tools and a valid guest login are required.
        case fileExistsInGuest(image: String, path: String)
        
        /// Deletes a specified file from the guest operating system. VMware Tools and a valid guest login are required.
        case deleteFileInGuest(image: String, path: String)
        
        /// Renames or moves a file in the guest operating system. VMware Tools and a valid guest login are required. Specify the source name (original) before the destination (new).
        case renameFileInGuest(image: String, path: String, newName: String)
        
        /// Creates the specified directory in the guest operating system. VMware Tools and a valid guest login are required.
        case createDirectoryInGuest(image: String, path: String)
        
        /// Deletes a directory from the guest operating system. VMware Tools and a valid guest login are required.
        case deleteDirectoryInGuest(image: String, path: String)
        
        /// Lists directory contents in the guest operating system. VMware Tools and a valid guest login are required.
        case listDirectoryInGuest(image: String, path: String)
        
        /// Copies a file from the host to the guest operating system. VMware Tools and a valid guest login are required.
        /// Specify the source file (host) before the destination file (guest).
        case copyFileFromHostToGuest(image: String, path: String, destination: String)
        
        /// Copies a file from the guest operating system to the host. VMware Tools and a valid guest login are required.
        /// Specify the source file (guest) before the destination file (host).
        case copyFileFromGuestToHost(image: String, path: String, destination: String)
        
        /// Captures the screen of the virtual machine to a local file. The specified output file on the host is in PNG format.
        ///     - Important: A valid guest login is required.
        case captureScreen(image: String, path: String)

        // MARK: Maintenance Commands
        
        public enum CloneOption: String {
            case full
            case linked
        }
        
        /// Lists all running virtual machines.
        case list
        
        /// Upgrades a virtual machine to the current version of virtual hardware. Has no effect if already current.
        case upgradevm(image: String)
        
        /// Prepares to install VMware Tools in the guest operating system. In Windows guests with autorun enabled, the VMware Tools installer starts by itself. In Linux guests without autorun, this command connects the virtual CD‐ROM drive to the VMware Tools ISO image suitable for the guest, but the installer does not start. You must complete the installation with additional manual steps, as described in your product documentation.
        case installtools(image: String)
        
        /// Registers a virtual machine (.vmx file), adding it to the host’s inventory. Path format depends on the product. ForVMwareServer2.0,"[storage1] vm/vm.vmx" (starting with the datastore) is typical.4
        ///     - Important: Registration not supported on VMware Workstation or on VMware Fusion
        case register(image: String)
        
        /// Unregisters a virtual machine (.vmx file), removing it from the host’s inventory. Path format depends on the product.ForServer2.0,"[storage1] vm/vm.vmx" (starting with the datastore) is typical.
        ///     - Important: Registration not supported on VMware Workstation or on VMware Fusion
        case unregister(image: String)
        
        /// Creates a copy of the virtual machine and guest. Provide the source .vmx file path name, and the destination .vmx file path name. You can create either a normal full clone or a linked clone. If you want to make the clone from a snapshot, rather than from the current virtual machine state, specify a snapshot name.
        ///     - Important: Cloning not supported on VMware Server or on VMware Fusion
        case clone(image: String, destination: String, clone: CloneOption, snapshotName: String? = nil)
        
        // MARK: VProbes Commands
        
        /// Shows the VProbes version on the virtual machine.
        ///     - Important: VMware Server does not support VProbes.
        case vprobeVersion(image: String)
        
        /// Loads the VProbes script on the virtual machine.
        ///     - Important: VMware Server does not support VProbes.
        case vprobeLoad(image: String, script: String)
        
        /// Disables all VProbes on the virtual machine.
        ///     - Important: VMware Server does not support VProbes.
        case vprobeReset(image: String)
        
        /// Lists the active VProbes on the virtual machine.
        ///     - Important: VMware Server does not support VProbes.
        case vprobeListProbes(image: String)
        
        /// Lists VProbes global variables on the virtual machine.
        ///     - Important: VMware Server does not support VProbes.
        case vprobeListGlobals(image: String)
        
    }
    
    let shell: Shell
    let software: Software
    
    // MARK: Public interface
    
    public init(_ connection: Shell.Connection, for software: Software = .fusion, on eventLoop: EventLoop) throws {
        shell = try Shell(connection, on: eventLoop)
        self.software = software
    }
    
    /// Send a command
    /// - Parameter command: command
    /// - Parameter output: Output stream (optional)
    public func send(command: Command, output: ((String) -> ())? = nil) -> EventLoopFuture<Void> {
        return shell.run(bash: compile(command), output: output).map { _ in
            return Void()
        }
    }
    
    // MARK: Private interface
    
    private func compile(_ command: Command) -> String {
        return "vmrun \(software.params) \(command.value)"
    }
    
}
