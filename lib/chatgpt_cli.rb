# frozen_string_literal: true

require_relative "chatgpt_cli/version"
require_relative "contexts"

require "quick_openai"
require "optparse"

module ChatGPT
  def gpt3(prompt, options)
    context = options[:context] || contexts[ENV["OPENAI_DEFAULT_CONTEXT"].to_sym]
    messages = [
      {role: "user", content: prompt}
    ]
    messages.unshift({role: "system", content: context}) if context

    parameters = {
      model: ENV["OPENAI_MODEL"],
      max_tokens: 4096,
      messages: messages,
  }.merge(options)

    response = QuickOpenAI.fetch_response_from_client do |client|
      client.chat(parameters: parameters)
    end

    text = response.dig("choices", 0, "message", "content")

    raise QuickOpenAI::Error, "Unable to parse response." if text.nil? || text.empty?

    text.chomp.strip
  end
end

module ChatGPTCLI
  class Error < StandardError; end

  def self.exe
    options = {}
    parser = OptionParser.new do |opts|
      opts.on('-c', '--context CONTEXT_KEY', 'Context key from contexts.rb') do |context_input|
        options[:context] = contexts.key?(context_input.to_sym) ? contexts[context_input.to_sym] : context_input
      end
      opts.on('-p', '--prompt PROMPT_TEXT', 'Prompt text to be passed to GPT-3') do |prompt_text|
        options[:prompt] = prompt_text
      end
    end

    remaining_args = parser.parse!(ARGV)

    input_from_pipe = $stdin.read if $stdin.stat.pipe?
    input_from_remaining_args = remaining_args.join(" ") if remaining_args.any?

    prompt = options[:prompt] || input_from_remaining_args || input_from_pipe || ""
    prompt.strip!

    chatgpt = ChatGPT.new
    puts chatgpt.gpt3(prompt, options)
  rescue QuickOpenAI::Error => e
    warn e.message
    exit 1
  end
end
