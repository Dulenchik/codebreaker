require "codebreaker/version"

module Codebreaker
  class Game
    def initialize
      reset
    end

    def play
      start
      begin
        begin
          read_guess
          make_respond
        end until end_game?
        save_result
        reset
      end while play_again?
      puts "See you soon"
    end

    private
      def start
        puts "Welcome to CodeBreaker!"
        puts "Try to guess what I propose"
      end

      def generate
        4.times { @cipher << rand(6) + 1 }
      end

      def reset
        @cipher, @guess, @respond, @attempts, @hint = [], [], [], 3, 0
        generate
      end

      def read_guess
        begin
          puts "Enter your guess (four numbers between 1 and 6#{ " or 'hint'" if @hint.zero? }):"
          check = (@guess = gets.scan(/[1-6hint]/).map { |item| item.to_i == 0 ? item : item.to_i }).size == 4
          puts "I don't understand... Try again" unless check 
        end until check
      end

      def make_respond
        @respond.clear
        @guess.each_with_index do |item, index|
          if @cipher[index] == item
            @respond << "+"
          else
            @respond << "-" if @cipher.include?(item)
          end
        end
        @respond.sort!
      end

      def end_game?
        result = false
        if @hint == 0 && @guess.join == "hint"
          show_hint
        else
          @attempts -= 1
          if @respond.join == "++++" || @attempts.zero?
            puts( @respond.join == "++++" ? "Congratulate! You won!" : "You lose, unfortunately..." )
            result = true
          else
            puts "Good try. Your result #{ @respond.join }"
          end
        end
        result
      end

      def show_hint(index = rand(4))
        @hint = @cipher[index]
        puts "I hint: #{ @hint } exist"
      end

      def save_result
        begin
          puts "Do you want to save your result? (y / n)"
          answer = gets.scan(/[yn]/).first
        end until answer == "y" || answer == "n"
        return if answer == "n"
        puts "Enter your name:"
        name = gets.chomp
        File.open("scores", "a") { |f| f.puts "#{ name }: #{ @attempts }" }
      end

      def play_again?
        begin
          puts "Do you want to play again? (y / n)"
          answer = gets.scan(/[yn]/).first
        end until answer == "y" || answer == "n"
        answer == "y" ? true : false
      end
  end
end
