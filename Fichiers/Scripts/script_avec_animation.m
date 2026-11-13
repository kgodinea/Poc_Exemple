%% Réinitialisation de l'espace de travail
clear;clc;close all;
Suppression_resultats

%% Définition des paramètres
definition_parametres
tic
%% CALCUL DE LA POSITION DU LASER A CHAQUE INSTANT D'INTEGRATION
disp("Interpolation de la trajectoire du laser")
position_laser = calcul_position_laser(vec_t_int, trajectoire_laser, v);

% suppression des points après la fin de la trajectoire
% on repère la fin de la trajectoire comme étant le 1er point à partir
% duquel il n'y a plus que des NaN dans trajectoire_laser
ind_fin_traj = min(find((diff(isnan(position_laser)) == 1)));

% supprimer les points après la fin de la trajectoire
if not(isempty(ind_fin_traj))
    vec_t_int = vec_t_int(1:ind_fin_traj);
    vec_t = vec_t(vec_t <= vec_t_int(ind_fin_traj));
    position_laser = position_laser(1:ind_fin_traj, :);
    disp("[Information] Fin de la trajectoire atteinte à t = " + num2str(vec_t(end)))
end

% affichage pour verification
if affichage
    figure("Name", "Trajectoire")
    title("Visualisation de la trajectoire")
    xlabel("x")
    ylabel("y")
    hold on
    plot(trajectoire_laser(:, 1), trajectoire_laser(:, 2))
    plot(position_laser(:, 1), position_laser(:, 2), ".")
    xlim([min(x), max(x)])
    ylim([min(y), max(y)])
end


% preparation de la colorbar pour l'affichage de la température

if affichage
    figure(2)
    col = colorbar();
    col.Limits = [300, T_solidus];
    col.LimitsMode = "manual";
    col.Visible = 'on';
end

%% CALCUL DE La TEMPERATURE

disp("Démarrage du calcul...")
parfor ind_t=1:length(vec_t)
    % calcul du champ de température à l'instant t
    t = vec_t(ind_t);
    %ind_t = find(vec_t == t);

    % nombre de points de la fonction à évaluer pour obtenir l'intégrale entre 0 et t
    n_points = (ind_t - 1) * ratio_pas_de_temps + 1 ; 
    
    %matrice qui contiendra la valeur de l'intégrale en chaque point de l'espace
    val_integrale = zeros(taille_grille) ;

    % matrice 3D pour les 2 coordonnées x, y et le temps (coordonnée z implicite car invariance selon z)
    distance_carre_au_laser = NaN(taille_grille(1:2)) ; 
    
    % pour chaque t' (appelé ici t_int), calculer la valeur de la fonction et
    % tout sommer à la fin en multipliant par dt_int
    for i=1:n_points
        % valeur de la fonction a integrer a chaque pas de temps de l'integrale
        t_int = vec_t_int(i); % variable muette de l'integrale
    
        % calcul du champ de distance carré au laser
        distance_carre_au_laser = calcul_champ_distance_carre_au_laser(x, y, position_laser(i, :));
        % obtention d'une matrice de dimension 2 qui est ensuite recopiée plein de fois selon z
        champ_distance_carre_au_laser = repmat(distance_carre_au_laser, 1, 1, length(z));
    
    
        % variables intermédiaires
        t_p = t - t_int ; % t'' defini dans le papier
        tau_p = (4*f_p*alpha*t_p + r_b^2)*sqrt(4*f_d*alpha*t_p + h^2) ; % tau''
        
    % calcul de l'intégrale (methode des rectangles) :
    % fonction évaluée en t_int et multipliée par dt_int, et on ajoute
    % cette valeur à ce qui a été précedemment calculé
    % les valeurs dans toute la grille sont calculées en même temps
        val_integrale = val_integrale + dt_int * (2*f_p*eta*P*sqrt(f_d))/(rho*C_0*pi*sqrt(pi)*tau_p) * ...
            exp(-(f_p*champ_distance_carre_au_laser)/(4*f_p*alpha*t_p + r_b^2) - (f_d*champ_z.^2)/(4*f_d*alpha*t_p + h^2));
    
    end
    % sommer toutes les valeurs obtenues pour la fonction à integrer et
    % multiplier par le dt_int (methode des rectangles)
    %val_integrale = sum(val_fct_integrale, 4)*dt_int;
    
    % Calcul de la température (eq 10)
    T = 1/m*(-1+sqrt(2*m*val_integrale + (1+m*T_0)^2));
    
    % sauvegarde des resultats pour y avoir acces apres le parfor
    for ind_z=1:taille_grille(3)
        writematrix(T(:, :, ind_z), "Results/Temperature_t" + num2str(ind_t) + "_z" + num2str(ind_z) + ".csv")
    end
    
    %affichage de l'avancement
    disp(num2str(100*(1-ind_t/length(vec_t))) + "%")
end
disp("Terminé !")
  

%% Affichage des résultats
if affichage
    figure(2)
    xlim([min(x), max(x)])
    ylim([min(y), max(y)])
    title("Température")
    xlabel('x')
    ylabel('y') 
    hold on
    caxis([300, T_solidus])
    % affichage du champ de température 
    for ind_t=1:length(vec_t)
        % lecture du fichier contenant le champ de température à l'instant
        % souhaité et au z souhaité
        T = readmatrix("Results/Temperature_t" + num2str(ind_t) + "_z" + num2str(z_affichage) + ".csv");
        imagesc('CData', T', 'XData', x, 'YData', y);
        plot(trajectoire_laser(:, 1), trajectoire_laser(:, 2), color="white")
        frames(ind_t) = getframe(gcf);

    end

    video = VideoWriter("video.avi");
    video.FrameRate = 24;
    open(video)
    for i=2:length(frames)
        writeVideo(video, frames(i))
    end
    close(video)
    
end

toc




   