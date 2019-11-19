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
    
    static func iphoneSimulator(name: String = "iPhone 11 Pro Max", iOSVersion: String = "13.2.2") -> String {
        return "platform=iOS Simulator,name=\(name),OS=\(iOSVersion)"
    }
}


class Fastfile: LaneFile {
    func runRadixTests(
        workspace: String? = nil,
        project: String? = RadixFastlaneConstants.projectFileName,
        scheme: String? = RadixFastlaneConstants.unitTestsScheme,
        device: String? = nil,
        devices: [String]? = nil,
        skipDetectDevices: Bool = false,
        forceQuitSimulator: Bool = false,
        resetSimulator: Bool = false,
        prelaunchSimulator: Bool? = nil,
        reinstallApp: Bool = false,
        appIdentifier: String? = nil,
        onlyTesting: Any? = nil,
        skipTesting: Any? = nil,
        xctestrun: String? = nil,
        toolchain: Any? = nil,
        clean: Bool = false,
        codeCoverage: Bool? = nil,
        addressSanitizer: Bool? = nil,
        threadSanitizer: Bool? = nil,
        openReport: Bool = false,
        outputDirectory: String = "./test_output",
        outputStyle: String? = nil,
        outputTypes: String = "html,junit",
        outputFiles: String? = nil,
        buildlogPath: String = "~/Library/Logs/scan",
        includeSimulatorLogs: Bool = false,
        suppressXcodeOutput: Bool? = nil,
        formatter: String? = nil,
        xcprettyArgs: String? = nil,
        derivedDataPath: String? = nil,
        shouldZipBuildProducts: Bool = false,
        resultBundle: Bool = false,
        useClangReportName: Bool = false,
        maxConcurrentSimulators: Int? = nil,
        disableConcurrentTesting: Bool = false,
        skipBuild: Bool = false,
        testWithoutBuilding: Bool? = nil,
        buildForTesting: Bool? = nil,
        sdk: String? = nil,
        configuration: String? = nil,
        xcargs: String? = nil,
        xcconfig: String? = nil,
        slackUrl: String? = nil,
        slackChannel: String? = nil,
        slackMessage: String? = nil,
        slackUseWebhookConfiguredUsernameAndIcon: Bool = false,
        slackUsername: String = "fastlane",
        slackIconUrl: String = "https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png",
        skipSlack: Bool = false,
        slackOnlyOnFailure: Bool = false,
        destination: Any? = RadixFastlaneConstants.Destination.iphoneSimulator(),
        customReportFileName: String? = nil,
        xcodebuildCommand: String = "env NSUnbufferedIO=YES xcodebuild",
        failBuild: Bool = true)
    {
        runTests(workspace: workspace, project: project, scheme: scheme, device: device, devices: devices, skipDetectDevices: skipDetectDevices, forceQuitSimulator: forceQuitSimulator, resetSimulator: resetSimulator, prelaunchSimulator: prelaunchSimulator, reinstallApp: reinstallApp, appIdentifier: appIdentifier, onlyTesting: onlyTesting, skipTesting: skipTesting, xctestrun: xctestrun, toolchain: toolchain, clean: clean, codeCoverage: codeCoverage, addressSanitizer: addressSanitizer, threadSanitizer: threadSanitizer, openReport: openReport, outputDirectory: outputDirectory, outputStyle: outputStyle, outputTypes: outputTypes, outputFiles: outputFiles, buildlogPath: buildlogPath, includeSimulatorLogs: includeSimulatorLogs, suppressXcodeOutput: suppressXcodeOutput, formatter: formatter, xcprettyArgs: xcprettyArgs, derivedDataPath: derivedDataPath, shouldZipBuildProducts: shouldZipBuildProducts, resultBundle: resultBundle, useClangReportName: useClangReportName, maxConcurrentSimulators: maxConcurrentSimulators, disableConcurrentTesting: disableConcurrentTesting, skipBuild: skipBuild, testWithoutBuilding: testWithoutBuilding, buildForTesting: buildForTesting, sdk: sdk, configuration: configuration, xcargs: xcargs, xcconfig: xcconfig, slackUrl: slackUrl, slackChannel: slackChannel, slackMessage: slackMessage, slackUseWebhookConfiguredUsernameAndIcon: slackUseWebhookConfiguredUsernameAndIcon, slackUsername: slackUsername, slackIconUrl: slackIconUrl, skipSlack: skipSlack, slackOnlyOnFailure: slackOnlyOnFailure, destination: destination, customReportFileName: customReportFileName, xcodebuildCommand: xcodebuildCommand, failBuild: failBuild)
    }
      
    func unitTestsLane() {
        desc("Builds sources, and runs unit tests.")
        runRadixTests()
    }
    
    func integrationTestsLane() {
        desc("Running local 'minimal-network' and runs integration tests with 'InegrationTests' scheme.")
        
        defer {
            sh(command: "docker-compose -f \(RadixFastlaneConstants.singleNodeNetworkYaml) down")
        }
        
        sh(command: "docker-compose -f \(RadixFastlaneConstants.singleNodeNetworkYaml) up -d")
        runRadixTests(
            scheme: RadixFastlaneConstants.integrationTestsScheme,
            clean: false,
            destination:  RadixFastlaneConstants.Destination.iphoneSimulator()
        )
    }
    
}
