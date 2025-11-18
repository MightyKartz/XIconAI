//
//  OpenAIProvider.swift
//  Icons Free Version - OpenAI Provider
//
//  Created by MightyKartz on 2024/11/18.
//

import Foundation

class OpenAIProvider: BaseAIProvider {

    private let baseURL = "https://api.openai.com/v1"

    override func testConnection() async -> Bool {
        do {
            let url = URL(string: "\(baseURL)/models")!
            let headers = ["Authorization": "Bearer \(config.apiKey)"]
            let (_, response) = try await makeRequest(url: url, headers: headers)
            return response.statusCode == 200
        } catch {
            return false
        }
    }

    override func generateImage(request: GenerationRequest) async throws -> GenerationResult {
        let startTime = Date()

        do {
            let url = URL(string: "\(baseURL)/images/generations")!

            let requestBody: [String: Any] = [
                "model": config.model,
                "prompt": request.prompt,
                "n": request.count,
                "size": request.size,
                "response_format": "b64_json"
            ]

            if let quality = request.quality {
                requestBody["quality"] = quality
            }

            if let style = request.style {
                requestBody["style"] = style
            }

            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            let headers = ["Authorization": "Bearer \(config.apiKey)"]

            let (data, _) = try await makeRequest(url: url, method: "POST", body: jsonData, headers: headers)

            let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)

            guard let firstImage = response.data.first else {
                throw APIError.providerError("没有返回图像")
            }

            let imageData = Data(base64Encoded: firstImage.b64_json) ?? Data()
            let processingTime = Date().timeIntervalSince(startTime)

            return GenerationResult(
                prompt: request.prompt,
                provider: .openai,
                model: config.model,
                imageData: imageData,
                processingTime: processingTime,
                isSuccessful: true
            )

        } catch {
            let processingTime = Date().timeIntervalSince(startTime)
            return GenerationResult(
                prompt: request.prompt,
                provider: .openai,
                model: config.model,
                processingTime: processingTime,
                isSuccessful: false,
                errorMessage: error.localizedDescription
            )
        }
    }
}

// MARK: - OpenAI Response Models

struct OpenAIResponse: Codable {
    let created: Int
    let data: [OpenAIImageData]
}

struct OpenAIImageData: Codable {
    let b64_json: String
    let revised_prompt: String?
}