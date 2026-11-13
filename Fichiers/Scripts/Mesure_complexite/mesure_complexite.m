% a executer 1 fois à l'initialisation
%essais = struct()

%% pour faire les mesures
%save("Mesure_complexite/essais_mesure_complexite.mat", "essais")
% tic
% script
% N_g = taille_grille(1) * taille_grille(2) * taille_grille(3) ;
% N_t = length(vec_t_int) ;
% temps = toc

load("Mesure_complexite/essais_mesure_complexite.mat")

% n_essai = input("numéro d'essai ?");
% essais(n_essai).taille_grille = N_g ;
% essais(n_essai).longueur_vecteur_temps = N_t ;
% essais(n_essai).temps_calcul = temps;

%% affichage du temps de calcul en fonction de N_g
figure(1)
valeurs_a_afficher = [];
for i=1:length(essais)
    if essais(i).longueur_vecteur_temps == 2011
        valeurs_a_afficher = [valeurs_a_afficher; essais(i).taille_grille, essais(i).temps_calcul];
    end
end
plot(valeurs_a_afficher(:, 1), valeurs_a_afficher(:, 2), "+", markersize=12)
xlabel("N_g")
ylabel("temps de calcul (s)")
legend("N_t = 2011")

%% affichage du temps de calcul en fonction de N_t
figure(2)
valeurs_a_afficher = [];
for i=1:length(essais)
    if essais(i).taille_grille == 30603
        valeurs_a_afficher = [valeurs_a_afficher; essais(i).longueur_vecteur_temps, essais(i).temps_calcul];
    end
end
plot(valeurs_a_afficher(:, 1), valeurs_a_afficher(:, 2), "+", markersize=12)
xlabel("N_t")
ylabel("temps de calcul (s)")
legend("N_g = 30603")


