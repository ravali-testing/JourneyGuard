public class Refresh {
    public static void main(String[] args) {
        // 1. Print numbers 1-100
        System.out.println("--- Challenge 1: Numbers 1 to 100 ---");
        for (int i = 1; i <= 100; i++) {
            System.out.print(i + " ");
        }
        System.out.println("\n");

        // 2. Reverse a string
        System.out.println("--- Challenge 2: Reverse a String ---");
        String original = "JourneyGuard";
        String reversed = new StringBuilder(original).reverse().toString();
        System.out.println("Original: " + original);
        System.out.println("Reversed: " + reversed + "\n");

        // 3. Check Even or Odd
        System.out.println("--- Challenge 3: Even or Odd ---");
        int num = 42;
        if (num % 2 == 0) {
            System.out.println(num + " is Even\n");
        } else {
            System.out.println(num + " is Odd\n");
        }

        // 4. Largest number in an array
        System.out.println("--- Challenge 4: Largest Number in Array ---");
        int[] arr = {12, 45, 78, 23, 56};
        int max = arr[0];
        for (int n : arr) {
            if (n > max) {
                max = n;
            }
        }
        System.out.println("The largest number is: " + max);
    }
}