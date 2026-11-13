# Documentation des codes

Tout tourne sous Matlab R2023a. Toutes les unités sont SI.

## Documentation des scripts

### definition_parametres.mlx

Livescript définissant toutes les variables et paramètres de calcul. Il contient également une petite partie de traitement de ces paramètres et il peut gérer quelques erreurs. Tout est détaillé dedans.

### script.m

Script effectuant le calcul du champ de température à l'instant _t_calcul_ renseigné dans [`definition_parametres.mlx`](#definition_parametresmlx). Fait appel aux fonctions [`calcul_position_laser.m`](#calcul_position_laserm), [`calcul_champ_distance_carre_au_laser.m`](#calcul_champ_distance_carre_au_laserm) et [`affichage_color_card.m`](#affichage_color_cardm).

Fonctionnement :

1. Réinitialisation de l'espace de travail et appel de [`definition_parametres.mlx`](#definition_parametresmlx).
2. Appel de la fonction [`calcul_position_laser.m`](#calcul_position_laserm) pour interpoler la trajectoire du laser à chaque point du vecteur temps _vec_t_int_ utilisé pour l'intégration. Si la trajectoire programmée est terminée avant la fin du vecteur temps, ce dernier est tronqué. La trajectoire est ensuite affichée sur un graphique.
3. Calcul de la température avec une boucle sur chaque point du vecteur temps d'intégration _vec_t_int_ :
   * Calcul du champ $d_\text{laser}^2$ par appel de la fonction [`calcul_champ_distance_carre_au_laser.m`](#calcul_champ_distance_carre_au_laserm). Le champ de coordonnée $z$ a été précalculé dans [`definition_parametres.mlx`](#definition_parametresmlx). Calcul de la fonction $f$ par opérations sur les grilles entières.
   * Calcul de l'intégrale de $f$ par méthode des rectangles
4. Calcul du champ de température à partir de $\int_0^t f(t')dt'$ qui a été calculée.
5. Affichage du champ de température sous forme d'une image avec dégradés, puis sous la forme d'une carte de couleur à la manière de celles présentées dans l'article en utilisant [`affichage_color_card.m`](#affichage_color_cardm).

### script_avec_animation.m

Effectue les calculs de la même manière que [`script.m`](#scriptm), mais donne le champ de température à chaque instant du vecteur temps donné en entrée. Ce script est beaucoup plus lourd en temps de calcul, mais il permet de se rendre plus facilement compte des évolutions temporelles de la température lorsque le laser se déplace. Génère également une petite animation stylée en vidéo ([exemple](cercle.avi)).

Fonctionnement :

1. Initialisation des variables et interpolation de la trajectoire du laser comme dans [`script.m`](#scriptm).
2. Calcul de la température à chaque pas de temps du vecteur temps _vec_t_ renseigné par l'utilisateur par une boucle `parfor` (avec parallelisation des calculs) contenant une boucle sur chaque point du vecteur temps d'intégration _vec_t_int_. Le calcul de la température à un instant $t$ fonctionne de la même manière que dans [`script.m`](#scriptm). Chaque champ de température est ensuite enregistré dans des fichiers csv dans le dossier "Results" pour les conserver sans remplir la mémoire RAM. Ces fichiers sont supprimés au lancement du script en appelant [`Suppression_resultats.m`](#suppression_resultatsm).
3. Affichage et enregistrement de chaque champ de température sous forme d'une animation.

### Suppression_resultats.m

Utilise des commandes DOS (risque de ne pas fonctionner sur d'autres OS que Windows) pour vider le dossier "Results" contenant tous les champs de température calculés par [`script_avec_animation.m`](#script_avec_animationm). Ce dernier appelle ce script en se lançant.

> [!WARNING]
> Ne rien mettre d'important dans le dossier "Results" !

### calcul_erreur_integrale.m

Script utilisé pour étudier l'influence de $\delta t$ sur la précision du calcul de l'intégrale de $f$.

Fonctionnement :

1. Initialisation de l'espace de travail, définition des coordonnées du point étudié et de l'instant considéré. Définition des paramètres matériaux et de la position du laser.
2. Création d'un vecteur de $\delta t$ à tester. Son premier élément est le pas de temps utilisé pour calculer la solution _overkill_.
3. Calcul de l'intégrale puis de la température pour chaque pas d'intégration.
4. Calcul puis affichage de l'erreur relative en fonction de $\delta t$.

> [!NOTE]
> Une vitesse du laser non nulle est renseignée bien que le spot laser soit immobile. A voir si cela a un effet sur les résultats obtenus.

### mesure_complexite.m

Programme utilisé pour mesurer le temps de calcul du programme [`script.m`](#scriptm) en fonction de la taille de grille $N_g$ et de la taille $N_t$ du vecteur temps d'intégration. Les résultats des essais effectués sont dans "essais_mesure_complexite.mat". Ce script ouvre les résultats et affiche les graphiques.

## Documentation des fonctions

### calcul_position_laser.m

Appelée par [`script.m`](#scriptm) et [`script_avec_animation.m`](#script_avec_animationm)

* Entrées : vecteur temps, liste des points de la trajectoire du laser, vitesse du laser
* Sorties : liste des points où le laser se trouve à chaque instant du vecteur temps

Interpole chaque segment entre les points donnés en entrée par des points distants de $dt/v$. Assemble les interpolations de chaque segment et gère les interfaces entre eux.

### calcul_champ_distance_carre_au_laser.m

Appelée par [`script.m`](#scriptm) et [`script_avec_animation.m`](#script_avec_animationm)

* Entrée : vecteurs _x_ et _y_ définissant la grille 3D et position du laser.
* Sortie : grille 2D contenant le carré de la distance entre chaque point et le centre du spot laser.

Fonctionnement : calcule le champ $d_\text{laser}^2$ sur une couche et recopie cette matrice autant de fois que nécessaire dans la direction z.

### affichage_color_card.m

Appelée par [`script.m`](#scriptm)

Entrée : champ de température (x, y) à afficher, vecteurs _x_ et _y_ et numéro de figure dont il faut reproduire l'échelle de couleur  
Sortie : (vide)

Affiche la carte de couleur comme les figures 4 et 6 de l'article.

Fonctionnement : effectue la somme des matrices booléennes résultantes de la comparaison du champ de température avec chacune des températures seuil de la carte de couleur à reproduire. On obtient alors une matrice contenant la valeurs _i_ aux endroits où il faut mettre la couleur n° _i_. Sur cette base, des matrices de couleur RGB sont créées puis affichées en tant qu'image.
