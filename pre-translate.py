import csv
import tkinter as tk
from tkinter import filedialog
import re


def load_glossary(filename):
    glossary = {}
    with open(filename, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            if row['swedish_standardised_term'] not in [None, ""] and row['english_standardised_term'] != [None, ""]:
                swedish_terms = row['swedish_standardised_term'].split(',')
                english_terms = row['english_standardised_term'].split(',')
                for swedish_term in swedish_terms:
                    glossary[swedish_term.strip()] = english_terms[0].strip()
                if row['swedish_alternatives'] != None:
                    for alternative in row['swedish_alternatives'].split(','):
                        alternative = alternative.strip()
                        if alternative:
                            glossary[alternative] = english_terms[0].strip()
            # else:
                # print("ill row",row)
    return glossary


def replace_terms(text, glossary):
    bracket_contents = []
    for swedish_term, english_term in glossary.items():
        for swedishSuffix in ['', 'en', 'ar', 'er', 'n']:
            for beforeWord in [' ', '\.', ',', ';', '\n', '\r', '\t', '/']:
                for afterWord in ["'", ' ', '\.', ',', ';', '\n', '\r', '\t', '/']:
                    swedish_expr = beforeWord+swedish_term+swedishSuffix+afterWord
                    bracket = '("<ID='+str(len(bracket_contents))+'/>")'
                    pre_translate_expr = beforeWord+english_term+" "+bracket+afterWord

                    text = re.sub(swedish_expr, pre_translate_expr,
                                  text, flags=re.IGNORECASE)
            bracket_contents.append(swedish_term + swedishSuffix) # swedish term could also be a swedish_alternative!

    # also replace some markdown stuff that deepl doesnt like:
    for annoying_character in ["##","#", "**", "*"]:
        text = text.replace(annoying_character, '<ID='+str(len(bracket_contents))+'/>')
        bracket_contents.append(annoying_character)
    return text, bracket_contents


def fill_brackets(text, bracket_contents):
    for i, bracket_content in enumerate(bracket_contents):
        text = text.replace('<ID='+str(i)+'/>', bracket_content)
    text = text.replace('*** Translated with www.DeepL.com/Translator (free version) ***\n', '')
    return text


if __name__ == '__main__':
    glossary = load_glossary('glossary.csv')
    root = tk.Tk()
    root.withdraw()
    input_path = filedialog.askopenfilename(
        title="Select input file", initialdir=".")
    with open(input_path, 'r', encoding='utf-8') as infile:
        text = infile.read()
    text, bracket_contents = replace_terms(text, glossary)
    path_and_name, extension = input_path.rsplit('.', 1)
    output_path = f"{path_and_name}.pre-translate.{extension}"
    with open(output_path, 'w', encoding='utf-8') as outfile:
        outfile.write(text)

    # wait for the user:
    input("Please run the file through deepl and then press Enter to continue to insert the bracket terms...")
    with open(output_path, 'r', encoding='utf-8') as second_stage:
        text = second_stage.read()
        text = fill_brackets(text, bracket_contents)
    with open(output_path, 'w', encoding='utf-8') as outfile:
        outfile.write(text)


# at the end use pattern  \("[^\)]*"\) to remove all unwanted occurances of f.ex. "sektionen"
