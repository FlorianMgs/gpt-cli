# frozen_string_literal: true

require_relative "gpt-cli/version"

require 'digest/md5'
require "json"
require "quick_openai"
require "optparse"

class ChatGPT
  attr_accessor :messages
  MESSAGES_FILE = 'message_history.json'

  def initialize
    @messages = load_messages
  end

  def save_messages
    File.open(MESSAGES_FILE, 'w') do |file|
      file.write(JSON.dump(@messages))
    end
  end

  def load_messages
    return [] unless File.exist?(MESSAGES_FILE)

    file_contents = File.read(MESSAGES_FILE)
    JSON.parse(file_contents, symbolize_names: true)
  end

  def contexts
    file_contents = File.read(ENV["OPENAI_CONTEXTS_PATH"])
    contexts = JSON.parse(file_contents)
    contexts.transform_keys(&:to_sym)
  end

  def gpt3(prompt, options)
    context = options[:context] || contexts[ENV["OPENAI_DEFAULT_CONTEXT"].to_sym]
    context_message = {role: "system", content: context.gsub("\n", ' ').squeeze(' ')}
    @messages << context_message if context && !@messages.include?(context_message)
    @messages << {role: "user", content: prompt}

    parameters = {
      model: ENV["OPENAI_MODEL"],
      max_tokens: 2048,
      messages: @messages,
    }
    
    response = QuickOpenAI.fetch_response_from_client do |client|
      client.chat(parameters: parameters)
    end

    text = response.dig("choices", 0, "message", "content")

    raise QuickOpenAI::Error, "Unable to parse response." if text.nil? || text.empty?
    
    @messages << {role: "assistant", content: text.chomp.strip}
    text.chomp.strip
  end
end

module GPTCLI
  class Error < StandardError; end

  def self.exe
    options = {}
    chatgpt = ChatGPT.new
    parser = OptionParser.new do |opts|
      opts.on('-c', '--context CONTEXT_KEY', 'Context key from contexts.json') do |context_input|
        options[:context] = chatgpt.contexts.key?(context_input.to_sym) ? chatgpt.contexts[context_input.to_sym] : context_input
      end
      opts.on('-p', '--prompt PROMPT_TEXT', 'Prompt text to be passed to GPT-3') do |prompt_text|
        options[:prompt] = prompt_text
      end
      opts.on('-h', '--history', 'Print the message history') do
        options[:history] = true
      end
      opts.on('--clear', 'Clear the message history') do
        options[:clear] = true
      end
      opts.on('-d', '--dalle', 'Use DALL-E instead of GPT. Prompt should be no more than 1000 characters.') do
        options[:dalle] = true
      end
    end

    remaining_args = parser.parse!(ARGV)

    if options[:history]
      puts chatgpt.messages
    elsif options[:clear]
      File.delete(ChatGPT::MESSAGES_FILE) if File.exist?(ChatGPT::MESSAGES_FILE)
      puts "Message history cleared."
    else
      input_from_pipe = $stdin.read if $stdin.stat.pipe?
      input_from_remaining_args = remaining_args.join(" ") if remaining_args.any?

      prompt = options[:prompt] || input_from_remaining_args || ""
      full_prompt = [prompt, input_from_pipe].compact.join("\n\n")
      full_prompt.strip!

      if options[:dalle]
        if full_prompt.length > 1000
          puts "Prompt is too long. Truncating to 1000 characters."
          full_prompt = full_prompt[0...1000]
        end
        full_prompt.dalle2.then { |tempfile|
          current_working_directory = Dir.pwd
          filename = Digest::MD5.hexdigest(full_prompt)
          output_file_path = File.join(current_working_directory, "#{filename}.png")
          File.write(output_file_path, tempfile.read)
          puts "Image saved in current directory to #{filename}.png"
        }
      else
        puts chatgpt.gpt3(full_prompt, options)
        chatgpt.save_messages
      end
    end
  rescue QuickOpenAI::Error => e
    warn e.message
    exit 1
  end
end