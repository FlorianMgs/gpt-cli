# frozen_string_literal: true

require_relative "gpt-cli/version"
require_relative "contexts"

require "quick_openai"
require "optparse"

class ChatGPT
  def contexts
    file_contents = File.read(File.join(File.dirname(__FILE__), 'contexts.rb'))
    instance_eval(file_contents)
  end

  def gpt3(prompt, options)
    context = options[:context] || contexts[ENV["OPENAI_DEFAULT_CONTEXT"].to_sym]
    messages = [
      {role: "user", content: prompt}
    ]
    messages.unshift({role: "system", content: context.gsub("\n", ' ').squeeze(' ')}) if context

    parameters = {
      model: ENV["OPENAI_MODEL"],
      max_tokens: 2048,
      messages: messages,
    }
    
    response = QuickOpenAI.fetch_response_from_client do |client|
      client.chat(parameters: parameters)
    end

    text = response.dig("choices", 0, "message", "content")

    raise QuickOpenAI::Error, "Unable to parse response." if text.nil? || text.empty?

    text.chomp.strip
  end
end

module GPTCLI
  class Error < StandardError; end

  def self.exe
    options = {}
    chatgpt = ChatGPT.new
    parser = OptionParser.new do |opts|
      opts.on('-c', '--context CONTEXT_KEY', 'Context key from contexts.rb') do |context_input|
        options[:context] = chatgpt.contexts.key?(context_input.to_sym) ? chatgpt.contexts[context_input.to_sym] : context_input
      end
      opts.on('-p', '--prompt PROMPT_TEXT', 'Prompt text to be passed to GPT-3') do |prompt_text|
        options[:prompt] = prompt_text
      end
    end

    remaining_args = parser.parse!(ARGV)

    input_from_pipe = $stdin.read if $stdin.stat.pipe?
    input_from_remaining_args = remaining_args.join(" ") if remaining_args.any?

    prompt = options[:prompt] || input_from_remaining_args || ""
    full_prompt = [prompt, input_from_pipe].compact.join("\n\n")
    full_prompt.strip!

    puts chatgpt.gpt3(full_prompt, options)
  rescue QuickOpenAI::Error => e
    warn e.message
    exit 1
  end
end
