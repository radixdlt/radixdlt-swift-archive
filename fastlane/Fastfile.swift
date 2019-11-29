import Foundation

enum RadixFastlaneConstants {}

extension RadixFastlaneConstants{
    static let projectFileName : String = "RadixSDK.xcodeproj"

    //schemes
    static let unitTestsScheme : String = "UnitTests"
    static let integrationTestsScheme : String = "IntegrationTests"
    static let radixSDKScheme : String = "RadixSDK iOS"
    static let exampleWalletScheme : String = "ExampleWallet"

    static let singleNodeNetworkYaml : String = "singleNodeNetwork.yml"
    static let twoNodesNetworkYaml : String = "twoNodesNetwork.yml"
    enum Destination {}
}

extension RadixFastlaneConstants.Destination {

    static func iphoneSimulator(targetPlatform : String = "iOS Simulator", name: String = "iPhone 11 Pro Max", iOSVersion: String = "13.2.2") -> String {
        return "platform=\(targetPlatform),name=\(name),OS=\(iOSVersion)"
    }
}


class Fastfile: LaneFile {


    func unitTestsLane() {
        desc("Builds sources, and runs unit tests.")
        runTests(
            project: RadixFastlaneConstants.projectFileName,
            scheme: RadixFastlaneConstants.unitTestsScheme
        )
    }

    func integrationTestsLane() {
        desc("Running local 'minimal-network' and runs integration tests with 'InegrationTests' scheme.")

        defer {
            print ("Bringing down the network...")
            sh(command: "docker-compose -f \(RadixFastlaneConstants.singleNodeNetworkYaml) down")
        }

        sh(command: "docker-compose -f \(RadixFastlaneConstants.singleNodeNetworkYaml) up -d")
        runTests(
            scheme: RadixFastlaneConstants.integrationTestsScheme,
            clean: false,
            destination:  RadixFastlaneConstants.Destination.iphoneSimulator()
        )
    }

}
