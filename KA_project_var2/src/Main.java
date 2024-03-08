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
                    long number = Long.parseLong(numStr);
                    if (number < Integer.MIN_VALUE || number > Integer.MAX_VALUE) {
                        System.out.printf("Введене число %d виходить за межі допустимого діапазону для int. Використовується максимальне значення: %d\n", number, Integer.MAX_VALUE);
                        number = Integer.MAX_VALUE;
                    }
                    System.out.printf("%d\n", number);
                    addToArray((int) number);
                }
            } catch (NumberFormatException e) {
                System.err.println("Введено нечислове значення. Спробуйте ще раз.");
            }
        }
        in.close();

//        System.out.println(Arrays.toString(numArray).replace("[", "").replace("]", " ").replace(",", ""));

        int[] sortedNumArray = numsMergeSort(numArray);
//        System.out.println(Arrays.toString(sortedNumArray).replace("[", "").replace("]", " ").replace(",", ""));

        int[] median = median(sortedNumArray);
        System.out.print("Median: ");
        System.out.println(Arrays.toString(median).replace("[", "").replace("]", " ").replace(",", ""));

        double avg = average(sortedNumArray);
        System.out.println("Average: " + avg);
    }

    public static void addToArray(int num) {
        numArray = Arrays.copyOf(numArray, numArray.length + 1);
        numArray[numArray.length - 1] = num;
    }

    public static int[] numsMergeSort(int[] array) {
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

    public static int[] numsMerge(int[] left, int[] right) {
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

    public static int[] median(int[] numArray) {
        if (numArray.length % 2 == 1) {
            return Arrays.copyOfRange(numArray, numArray.length / 2, numArray.length / 2 + 1);
        } else {
            return Arrays.copyOfRange(numArray, numArray.length / 2 - 1, numArray.length / 2 + 1);
        }
    }

    public static double average(int[] numArray) {
        return Arrays.stream(numArray).sum() / (double) numArray.length;
    }
}