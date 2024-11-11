// Krista Cherry
// CSE 143 AK
// 5/22/2021
// Assignment #6
//
// This class allows a client to find all possible anagrams of a
// chosen word with the possible words for the anagram in
// a given dictionary of words (it considers
// the order of words in the anagram to be distinct).
// For example, the client could construct the object with a
// dictionary of 4 words "bee, go, gush, shrug"
// and call the print method with the string "george bush"
// which would print to System.out
// [bee, go, shrug]
// [bee, shrug, go]
// [go, bee, shrug]
// [go, shrug, bee]
// [shrug, bee, go]
// [shrug, go, bee]
// The print method ignores case and nonletter characters.
// e.g., a client could call "GeORGE   ....busH"
// and the method would produce the same result.

import java.util.*;

public class AnagramSolver {
   
   private Map<String, LetterInventory> dictionary;
   private List<String> words;
   
   // This constructor creates the AnagramSolver object.
   // List<String> "list" is the list of strings
   // that is the dictionary of all possible
   // words the client would like the anagram solver
   // to consider when it finds anagrams.
   public AnagramSolver(List<String> list) {
      words = list;
      dictionary = new HashMap<>();
      for (String s : words) {
         dictionary.put(s, new LetterInventory(s));
      }
   }
   
   // This method prints to System.out all possible anagrams for the
   // passed in string from the dictionary used when the object
   // was constructed.
   // Each anagram is printed on a seperate line of output.
   // Each anagram is surrounded by brackets and has
   // commas between each word.
   // e.g. an anagram "go bee shrug" would print "[go, bee, shrug]"
   // String "s" is the string that the method prints anagrams for.
   // int "max" is the maximum number of words to be included in
   // the anagram for s (a maximum -- i.e. 1 word - max words).
   // The method prints anagrams in the order of the passed in dictionary
   // when the object was constructed.
   // It considers different orders of words within the anagram to be distinct.
   // The method ignores the capitalization of s
   // and any nonletter characters (e.g. " " or ".").
   // The method doesn't produce any output if no anagrams for s exist.
   // The method throws an IllegalArgumentException if "max" is less than zero.
   public void print(String s, int max) {
      if (max < 0) {
         throw new IllegalArgumentException();
      }
      LetterInventory lettersForAnagram = new LetterInventory(s);
      List<String> smallerDictionary = new LinkedList<>();
      for (String key : words) {
         LetterInventory possibleNewInventory = lettersForAnagram.subtract(dictionary.get(key));
         if (possibleNewInventory != null) {
            smallerDictionary.add(key);
         }
      }
      List<String> setOfAnagrams = new LinkedList<>();
      explore(lettersForAnagram, max, smallerDictionary, setOfAnagrams);
   }
   
   // This is the recursive method for this class.
   // It searches through passed in dictionary
   // and creates a list of strings
   // to build up the possible anagrams
   // for a given word.
   // LetterInventory "lettersForAnagram" is the
   // letter inventory of the passed in word that gets
   // decremented on each call.
   // int "max" is the maximum number of words for the
   // set of words making up the anagram.
   // List<String> smallerDictionary is the pruned
   // dictionary passed in at the beginning from the print method.
   // List<String> setOfAnagrams gets build up on each
   // It does NOT prune the dictionary on each call
   // so, the passed in smallerDictionary doesn't change.
   private void explore(LetterInventory lettersForAnagram, int max,
   List<String> smallerDictionary, List<String> setOfAnagrams) {
      if (lettersForAnagram.isEmpty()) {
         System.out.println(setOfAnagrams.toString());
      } else {
         if (setOfAnagrams.size() != max || max == 0) {
            for (String s : smallerDictionary) {
               LetterInventory possibleNewInventory = lettersForAnagram.subtract(dictionary.get(s));
               if (possibleNewInventory != null) {
                  setOfAnagrams.add(s);
                  explore (possibleNewInventory, max, smallerDictionary, setOfAnagrams);
                  setOfAnagrams.remove(s);
               }
            }
         }
      }
   }
}