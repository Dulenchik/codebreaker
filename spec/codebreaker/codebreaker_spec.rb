require "spec_helper"

module Codebreaker
  describe Game do
    let(:game) { Game.new.as_null_object }
    after(:all) { File.delete("scores") }

    context "public methods" do
      context "#initialize" do
        it "calls #reset method" do
          game.should_receive(:reset)
          game.send(:initialize)
        end
      end

      context "#play" do
        before(:each) do
          game.stub(:read_guess)
          game.stub(:save_result)
          game.stub(:play_again?)
        end
        after(:each) { game.play }

        it "call #start" do
          game.should_receive(:start)
        end

        it "call #read_guess" do
          game.should_receive(:read_guess)
        end

        it "call #make_respond" do
          game.should_receive(:make_respond)
        end

        it "call #end_game?" do
          game.should_receive(:end_game?)
        end

        it "call #save_result" do
          game.should_receive(:save_result)
        end

        it "call #reset" do
          game.should_receive(:reset)
        end

        it "call #play_again?" do
          game.should_receive(:play_again?)
        end

        it "shows goodbye message" do
          game.should_receive(:puts).with("See you soon")
        end
      end
    end

    context "private methods" do
      context "#start" do
        after(:each) { game.send(:start) }
        it "shows welcome message" do
          game.should_receive(:puts).with("Welcome to CodeBreaker!")
        end

        it "proposes enter the first guess" do
          game.should_receive(:puts).with("Try to guess what I propose")
        end
      end

      context "#generate" do
        it "makes 4 items" do
          game.instance_variable_get(:@cipher).should have(4).items          
        end

        it "cipher have values between 1 and 6" do
          game.instance_variable_get(:@cipher).should have_items_in_range(1..6)
        end
      end

      context "#reset" do
        context "resets settings" do
          before(:each) { game.send(:reset) }
          it "makes @attempts equal to 3" do
            game.instance_variable_get(:@attempts).should eql(3)
          end

          it "makes @hint equal to 0" do
            game.instance_variable_get(:@hint).should be_zero
          end

          it "makes @guess empty" do
            game.instance_variable_get(:@guess).should be_empty
          end

          it "makes @respond empty" do
            game.instance_variable_get(:@respond).should be_empty
          end
        end

        it "generate new cipher" do
          game.should_receive(:generate)
          game.send(:reset)
        end
      end

      context "#read_guess" do
        context "guess have < 4 items" do
          it "show warning message" do
            game.stub(:gets).and_return("11111", "1111")
            game.should_receive(:puts).with("I don't understand... Try again")
            game.send(:read_guess)
          end
        end

        context "guess have 4 items" do
          before(:each) { game.stub(:gets).and_return("1111") }
          it "show proposal message (hint not use)" do
            game.should_receive(:puts).with("Enter your guess (four numbers between 1 and 6 or 'hint'):")
            game.send(:read_guess)
          end

          it "show proposal message (hint use already)" do
            game.instance_variable_set(:@hint, 1)
            game.should_receive(:puts).with("Enter your guess (four numbers between 1 and 6):")
            game.send(:read_guess)
          end

          it "reads guess" do
            game.send(:read_guess)
            game.instance_variable_get(:@guess).should eql([1, 1, 1, 1])
          end
        end

        it "saves 'hint' like chars" do
          game.stub(:gets).and_return("hint")
          game.send(:read_guess)
          game.instance_variable_get(:@guess).should eql(["h", "i", "n", "t"])
        end
      end

      context "#make_respond" do
        before(:each) do
          game.instance_variable_set(:@cipher, [1, 2, 3, 4])
          game.instance_variable_set(:@guess, [3, 2, 4, 5])
        end

        it "makes new respond" do
          game.instance_variable_get(:@respond).should_receive(:clear)
          game.send(:make_respond)
        end

        it "respond have only '+' and '-'" do
          game.send(:make_respond)
          game.instance_variable_get(:@respond).should have_items_in_range(["+", "-"])
        end

        it "sorts respond" do
          game.instance_variable_get(:@respond).should_receive(:sort!)
          game.send(:make_respond)
        end

        it "makes correct result" do
          game.send(:make_respond)
          game.instance_variable_get(:@respond).should eql(["+", "-", "-"])
        end
      end

      context "#end_game?" do
        context "return boolean value" do
          it "return true if player win" do
            game.instance_variable_set(:@respond, ["+", "+", "+", "+"])
            game.send(:end_game?).should be true
          end

          it "return true if player lose" do
            game.instance_variable_set(:@respond, ["+", "+", "+"])
            game.instance_variable_set(:@attempts, 1)
            game.send(:end_game?).should be true
          end

          it "return false" do
            game.instance_variable_set(:@respond, ["+", "+", "+"])
            game.instance_variable_set(:@attempts, 2)
            game.send(:end_game?).should be false
          end

          it "use 'hint' also return false" do
            game.stub(:show_hint)
            game.instance_variable_set(:@guess, ["h", "i", "n", "t"])
            game.send(:end_game?).should be false
          end
        end

        context "calling #show_hint" do
          after(:each) { game.send(:end_game?) }

          it "call #show_hint" do
            game.instance_variable_set(:@guess, ["h", "i", "n", "t"])
            game.should_receive(:show_hint)            
          end

          it "not call #show_hint" do
            game.instance_variable_set(:@guess, ["h", 1, "n", "t"])
            game.should_not_receive(:show_hint)            
          end

          it "not call #show_hint also" do
            game.instance_variable_set(:@guess, ["i", "h", "t", "n"])
            game.should_not_receive(:show_hint)            
          end

          it "call #show_hint once" do
            game.instance_variable_set(:@guess, ["h", "i", "n", "t"])
            game.instance_variable_set(:@hint, 5)
            game.should_not_receive(:show_hint)
          end
        end

        context "shows messages" do
          after(:each) { game.send(:end_game?) }

          it "shows win message" do
            game.instance_variable_set(:@respond, ["+", "+", "+", "+"])
            game.should_receive(:puts).with("Congratulate! You won!")
          end

          it "shows lose message" do
            game.instance_variable_set(:@respond, ["+", "+", "+"])
            game.instance_variable_set(:@attempts, 1)
            game.should_receive(:puts).with("You lose, unfortunately...")
          end

          it "shows result message" do
            game.instance_variable_set(:@respond, ["+", "+", "+"])
            game.instance_variable_set(:@attempts, 2)
            game.should_receive(:puts).with("Good try. Your result +++")
          end
        end

        context "number of attempts" do
          before(:each) { game.instance_variable_set(:@attempts, 2) }

          it "change @attempts value" do
            expect { game.send(:end_game?) }.to change{ game.instance_variable_get(:@attempts) }.from(2).to(1)
          end

          it "#show_hint not change @attempts value if called for the first time" do
            game.stub(:show_hint)
            game.instance_variable_set(:@guess, ["h", "i", "n", "t"])
            expect { game.send(:end_game?) }.not_to change{ game.instance_variable_get(:@attempts) }
          end

          it "#show_hint change @attempts value if already called" do
            game.stub(:show_hint)
            game.instance_variable_set(:@hint, 5)
            game.instance_variable_set(:@guess, ["h", "i", "n", "t"])
            expect { game.send(:end_game?) }.to change{ game.instance_variable_get(:@attempts) }.from(2).to(1)
          end
        end
      end

      context "#show_hint" do
        before(:each) { game.instance_variable_set(:@cipher, [1, 2, 3, 4]) }
        it "shows hint message" do
          game.should_receive(:puts).with("I hint: 3 exist")
          game.send(:show_hint, 2)
        end

        it "change @hint value" do
          expect { game.send(:show_hint, 2) }.to change{ game.instance_variable_get(:@hint) }.from(0).to(3)
        end
      end

      context "#save_result" do
        context "provides a dialogue with the user" do
          after(:each) { game.send(:save_result) }

          it "shows question message" do
            game.stub(:gets).and_return("n")
            game.should_receive(:puts).with("Do you want to save your result? (y / n)")
          end

          it "repeatedly asks the question" do
            game.stub(:gets).and_return("b", "n")
            game.should_receive(:puts).with("Do you want to save your result? (y / n)").twice
          end

          it "reads answer and shows proposal message" do
            game.stub(:gets).and_return("y")
            game.should_receive(:puts).with("Enter your name:")
          end

          it "reads name" do
            game.stub(:gets).and_return("y", "Lesha")
            File.should_receive(:open).with("scores", "a")
          end

          it "not asks name when answer equal 'n'" do
            game.stub(:gets).and_return("n")
            game.should_not_receive(:puts).with("Enter your name:")
          end
        end

        context "work with file" do
          before(:each) { game.stub(:gets).and_return("y", "Lesha") }

          it "create file 'scores'" do
            game.send(:save_result)          
            File.should be_exist("scores")
          end

          it "write from file 'scores'" do
            expect { game.send(:save_result) }.to change{ File.open("scores").read.count("\n") }
          end
        end
      end

      context "#play_again?" do
        context "provides a dialogue with the user" do
          after(:each) { game.send(:play_again?) }

          it "shows question message" do
            game.stub(:gets).and_return("n")
            game.should_receive(:puts).with("Do you want to play again? (y / n)")
          end

          it "repeatedly asks the question" do
            game.stub(:gets).and_return("b", "n")
            game.should_receive(:puts).with("Do you want to play again? (y / n)").twice
          end
        end

        context "returns boolean value" do
          it "returns true if answer is 'y'" do
            game.stub(:gets).and_return("y")
            game.send(:play_again?).should be true
          end

          it "returns false if answer is 'n'" do
            game.stub(:gets).and_return("n")
            game.send(:play_again?).should be false
          end
        end
      end
    end
  end
end