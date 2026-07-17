# 1. Read and print a list
print("--- Challenge 1: Read and Print a List ---")
my_list = ["Train", "Bus", "Tram"]
for item in my_list:
    print(f"Transport option: {item}")
print()

# 2. Count words in a sentence
print("--- Challenge 2: Count Words in a Sentence ---")
sentence = "JourneyGuard makes rail travel easy and safe"
words = sentence.split()
print(f"Sentence: '{sentence}'")
print(f"Word Count: {len(words)}\n")

# 3. Reverse a string
print("--- Challenge 3: Reverse a String ---")
text = "Automation"
reversed_text = text[::-1]
print(f"Original: {text}")
print(f"Reversed: {reversed_text}\n")

# 4. Handle a simple exception with try/except
print("--- Challenge 4: Try/Except Exception Handling ---")
try:
    print("Attempting to divide 10 by 0...")
    result = 10 / 0
except ZeroDivisionError:
    print("Caught an error: You cannot divide a number by zero!")