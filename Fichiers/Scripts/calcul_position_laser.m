function position_laser = calcul_position_laser(t, traj_laser, vitesse_laser)
% Fonction qui calcule la position du laser à chaque instant du vecteur t
% sachant les points de la trajectoire du laser et sa vitesse

position_laser = NaN(length(t), 2);

direction_laser = diff(traj_laser, 1);
distances_entre_points = sqrt(sum(diff(traj_laser, 1).^2, 2));
abscisse_curviligne = cumsum(distances_entre_points);

dt = t(2) - t(1) ; % pas de temps supposé constant

point_depart = traj_laser(1, :);

% temps du debut du track 1
ind_t1 = 1; 
for i=1:length(abscisse_curviligne)
    % temps auquel le track i se termine
    t2 = abscisse_curviligne(i)/vitesse_laser;

    % recherche de t2 dans le vecteur t, on veut trouver le plus grand
    % élément de t parmi ceux inférieurs à t2
    [~ ,ind_t2] = min(abs(t - t2)); 
    if t(ind_t2) >= t2
        ind_t2 = ind_t2 - 1;
    end
    % calcul de l'écart entre t2 et le t(ind_t2 + 1)
    % t_residu est l'intervalle de temps qui s'écoule entre l'instant où le
    % laser passe par le point définissant la trajectoire et le prochain instant
    % appartenant au vecteur temps
    t_residu = t(ind_t2) + dt - t2;
    
    % calcul de la position du laser sur le track i entier
    position_laser(ind_t1:ind_t2, :) = repmat(point_depart, ind_t2-ind_t1+1, 1) + ... % position de départ
        diag(0:1:(ind_t2 - ind_t1)) * repmat(direction_laser(i, :)/norm(direction_laser(i, :)), ind_t2-ind_t1+1, 1) * vitesse_laser * dt; % + le déplacement du laser au cours du temps

    % initialisation de la boucle suivante en enregistrant les données du
    % track i+1
    if i ~=length(abscisse_curviligne)
        point_depart = traj_laser(i+1, :) + t_residu * vitesse_laser * direction_laser(i+1, :)/norm(direction_laser(i+1, :)) ;
        ind_t1 = ind_t2 + 1;
    end
end





end