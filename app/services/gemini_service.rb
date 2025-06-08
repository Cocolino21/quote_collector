class GeminiService
    include HTTParty
    
    BASE_URL = 'https://generativelanguage.googleapis.com/v1beta'
    
    def initialize
      @api_key = ENV['GEMINI_API_KEY']
    end
    
    def generate_random_quote
      prompt = "Generate a single inspirational quote. Respond with ONLY a JSON object in this exact format (no other text):
  {
    \"content\": \"the quote text without quotation marks\",
    \"author\": \"author name or 'Anonymous' if you create it\",
    \"category\": \"single word like Motivation, Wisdom, Success, Life, Love, etc\"
  }"
      
      begin
        response = HTTParty.post(
          "#{BASE_URL}/models/gemini-pro:generateContent?key=#{@api_key}",
          headers: {
            'Content-Type' => 'application/json'
          },
          body: {
            contents: [{
              parts: [{
                text: prompt
              }]
            }],
            generationConfig: {
              temperature: 0.9,
              maxOutputTokens: 200
            }
          }.to_json
        )
        
        if response.success?
          generated_text = response.dig('candidates', 0, 'content', 'parts', 0, 'text')
          
          clean_text = generated_text.gsub(/```json|```/, '').strip
          
          quote_data = JSON.parse(clean_text)
          
          {
            content: quote_data['content'],
            author: quote_data['author'], 
            category: quote_data['category']
          }
        else
          fallback_quote
        end
        
      rescue JSON::ParserError => e
        Rails.logger.error "JSON Parse Error: #{e.message}"
        Rails.logger.error "Response was: #{generated_text}" if defined?(generated_text)
        fallback_quote
      rescue => e
        Rails.logger.error "Gemini API Error: #{e.message}"
        fallback_quote
      end
    end
    
    private
    
    def fallback_quote
      quotes = [
        {
          content: "The only way to do great work is to love what you do",
          author: "Steve Jobs",
          category: "Motivation"
        },
        {
          content: "Innovation distinguishes between a leader and a follower",
          author: "Steve Jobs", 
          category: "Innovation"
        },
        {
          content: "The future belongs to those who believe in the beauty of their dreams",
          author: "Eleanor Roosevelt",
          category: "Dreams"
        },
        {
          content: "Success is not final, failure is not fatal: it is the courage to continue that counts",
          author: "Winston Churchill",
          category: "Success"
        }
      ]
      
      quotes.sample
    end
  end