function [outputArg1] = affichage_color_card(T, x, y, n_fig)
% afficher la carte de couleur de la température 
%   à l'instant t = vec_t(ind_t) 
%   à la hauteur z = z(ind_z) 
% avec des seuils comme sur la Fig 4/Fig.6.

% extraction du champ de température à l'instant et à la hauteur indiquée
champ_T = T';
couleur = ones(size(champ_T));

% creation des matrices pour chaque couleur
R = NaN(size(couleur));
G = NaN(size(couleur));
B = NaN(size(couleur));

if n_fig == 4
    % definition des seuils de température
    seuils_temperature = [523 823 1123 1878 1923];
    
    RGB_couleurs = [197 194 187; % code rgb de chaque couleur
                      0   3 146;
                      1 140 169;
                    117 182 100;
                    243 125   2;
                    159   3   6];
elseif n_fig == 6
    % definition des seuils de température
    seuils_temperature = [1123 1533 1609 2900];

    RGB_couleurs = [197 194 187; % code rgb de chaque couleur
                    117 181 97;
                    172  88  0;
                    159   1  0;
                    192 174  2];
end
% remplissage de la matrice couleur
% ex pour n_fig = 4 :
% couleur = 1 pour les points où T<523K
% couleur = 2 pour les points où T<823K, etc.
for i=1:length(seuils_temperature)
    couleur = couleur + (champ_T > seuils_temperature(i));
end

% conversion de la matrice couleur en code RGB pour créer l'image
for i=1:length(seuils_temperature)+1
    R(couleur == i) = RGB_couleurs(i, 1);
    G(couleur == i) = RGB_couleurs(i, 2);
    B(couleur == i) = RGB_couleurs(i, 3);
end

% affichage de l'image
CData = cat(3, R, G, B)/255;
image('CData', CData, 'XData', x, 'YData', y)

end