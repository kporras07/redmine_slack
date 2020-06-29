module SlashCommandsHelper

    def validRequest?(headers, body, signing_secret)
        timestamp = headers['X-Slack-Request-Timestamp']
        signature = headers['X-Slack-Signature']
        string_to_validate = "v0:#{timestamp}:#{body}"
        digest = OpenSSL::Digest.new('sha256')
        signed = OpenSSL::HMAC.hexdigest(digest, signing_secret, string_to_validate)
        "v0=#{signed}" == signature
    end
end
