# script python
# test yan LUCAS

# -*-coding:Latin-1 -*

import os # On importe le module os qui dispose de variables
          # et de fonctions utiles pour dialoguer avec votre
          # système d'exploitation

# Programme testant si une année, saisie par l'utilisateur, est bissextile ou non

annee = input("Saisissez une année superieure à zero : ") # On attend que l'utilisateur fournisse l'année qu'il désire tester

try:
    annee = int(annee) # On tente de convertir l'année
    if annee<=0:
        raise ValueError("l'année saisie est négative ou nulle")
except ValueError:
    print("La valeur saisie est invalide (l'année est peut-être négative).")

#annee = int(annee) # Risque d'erreur si l'utilisateur n'a pas saisi un nombre

if annee % 400 == 0 or (annee % 4 == 0 and annee % 100 != 0):
    print("L'année saisie est bissextile.")
else:
    print("L'année saisie n'est pas bissextile.")

# On met le programme en pause pour éviter qu'il ne se referme (Windows)
os.system("pause")