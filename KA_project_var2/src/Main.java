import java.util.Arrays;
import java.util.Scanner;

public class Main {

    static int[] numArray = new int[0];

    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);

        while (in.hasNextLine()) {
            String input = in.nextLine();
            if (input.isEmpty()) {
                break;
            }

            String[] numbersStr = input.split("\\s+");
            try {
                for (String numStr : numbersStr) {
                    int number = Integer.parseInt(numStr);
                    System.out.printf("%d\n", number);
                    addToArray(number);
                }
            } catch (NumberFormatException e) {
                System.err.println("Введено нечислове значення. Спробуйте ще раз.");
            }
        }
            in.close();


            System.out.println(Arrays.toString(numArray));
            int[] sortedNumArray = numsMergeSort(numArray);
            System.out.println(Arrays.toString(sortedNumArray));
        }

        public static void addToArray ( int num){
            numArray = Arrays.copyOf(numArray, numArray.length + 1);
            numArray[numArray.length - 1] = num;
        }

        public static int[] numsMergeSort ( int[] array){
            if (array.length <= 1) {
                return array;
            }

            int[] left = new int[array.length / 2];
            int[] right = new int[array.length - left.length];

            System.arraycopy(array, 0, left, 0, left.length);
            System.arraycopy(array, left.length, right, 0, right.length);

            left = numsMergeSort(left);
            right = numsMergeSort(right);

            return numsMerge(left, right);
        }

        public static int[] numsMerge ( int[] left, int[] right){
            int[] result = new int[left.length + right.length];

            int leftIndex = 0;
            int rightIndex = 0;
            int resultIndex = 0;

            while (leftIndex < left.length && rightIndex < right.length) {
                if (left[leftIndex] >= right[rightIndex]) {
                    result[resultIndex++] = right[rightIndex++];
                } else {
                    result[resultIndex++] = left[leftIndex++];
                }
            }

            while (leftIndex < left.length) {
                result[resultIndex++] = left[leftIndex++];
            }

            while (rightIndex < right.length) {
                result[resultIndex++] = right[rightIndex++];
            }

            return result;
        }
    }