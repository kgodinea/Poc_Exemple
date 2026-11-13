function distance_carre_au_laser = calcul_champ_distance_carre_au_laser(x, y, position_laser)
% fonction qui renvoie le champ (invariant selon z) : (x-xl)^2 + (y-yl)^2
% avec xl, yl la position du laser donnée en entrée
% x, y et sont les vecteurs de coordonnées selon x, y
% position_laser est la position du laser à l'instant considéré

max_ind_x = length(x);
max_ind_y = length(y);

%% calculer le champ de distance au laser
distance_carre_selon_x = (x - position_laser(1)).^2;
distance_carre_selon_y = (y - position_laser(2)).^2;

distance_carre_au_laser = repmat(distance_carre_selon_x', [1, max_ind_y]) + repmat(distance_carre_selon_y, [max_ind_x, 1]);

end