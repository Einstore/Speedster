import Foundation


struct Scripts {
    
    static var machine: String {
        return """
            unameOut="$(uname -s)"
            case "${unameOut}" in
            Linux*)     machine=Linux;;
            Darwin*)    machine=Mac;;
            CYGWIN*)    machine=Cygwin;;
            MINGW*)     machine=MinGw;;
            *)          machine="UNKNOWN:${unameOut}"
            esac
            echo ${machine}
            """
    }
    
    static var numberOfCores: String {
        return "sysctl hw.physicalcpu hw.logicalcpu"
    }
    
    static var installDockerUbuntu: String {
        return """
        sudo apt-get update && apt-get install \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common \
            -y
        
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        
        sudo apt-key fingerprint 0EBFCD88
        
        sudo add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"
        
        sudo apt-get update && apt-get install docker-ce docker-ce-cli containerd.io -y
        
        sudo docker run hello-world
        
        echo "Install docker-machine"
        base=https://github.com/docker/machine/releases/download/v0.16.0 &&
            curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
            sudo install /tmp/docker-machine /usr/local/bin/docker-machine
        """
    }
    
}
