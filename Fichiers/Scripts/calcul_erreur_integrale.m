%% Réinitialisation de l'espace de travail
clear;clc;close all;

%% Initialisation des variables
% position observée dans l'espace
x = 1e-5;
y = 0;
z = 0;
t = 1e-3;

% spot laser
position_laser = [0 0];
v = 1;

% parametres du Ti6Al4V 
T_0 = 300 ;
m = 1.18e-3 ;
f_p = 1.0 ;
f_d = 2.0 ;
r_b = 0.05e-3 ;
eta = 0.60 ;
P = 60 ;
rho = 4200 ;
C_0 = 260 ;
alpha = 8.06e-6 ;

h = r_b * 0.08 * ((eta*P*r_b/v)/(pi*r_b^2 * sqrt(alpha*r_b/v)) * 1/(rho*830*1878))^1.4;

% pas de temps de la solution overkill
dt_int_overkill = 1e-10;

% pas de temps testés
vec_dt_int = [dt_int_overkill, logspace(-8, -5, 50)];

meth_trapz = NaN(length(vec_dt_int)-1, 1);
meth_rect = NaN(length(vec_dt_int)-1, 1);

%% Calcul de la température pour chaque dt_int de vec_dt_int
for i=1:length(vec_dt_int) %pour chaque pas de temps à tester
    % creation du vecteur temps
    dt_int = vec_dt_int(i);
    vec_t_int = 0:dt_int:t;
    
    % calcul de la position du laser et du champ de distance au laser
    distance_carre_au_laser = (position_laser(:, 1) - x).^2 + (position_laser(:, 2) - y).^2 ;
    % variables intermédiaires    
    t_p = t - vec_t_int' ; % t'' defini dans le papier
    tau_p = (4*f_p*alpha*t_p + r_b^2).*sqrt(4*f_d*alpha*t_p + h^2) ; % tau''
    
    % calcul de la fonction à integrer (en fonction de t_p)
    val_fct_integrale = (2*f_p*eta*P*sqrt(f_d))./(rho*C_0*pi*sqrt(pi)*tau_p) .* ...
            exp(-(f_p*distance_carre_au_laser)./(4*f_p*alpha*t_p + r_b^2) - (f_d*z^2)./(4*f_d*alpha*t_p + h^2));
    
    % fonction à integrer = energie apportée par un flash en fonction de à quel point il est vieux
    %plot(t_p, val_fct_integrale) 
    
    if i == 1 % cas de la solution overkill
        sol_overkill = trapz(flip(t_p), val_fct_integrale);
        T_overkill = 1/m*(-1+sqrt(2*m*sol_overkill + (1+m*T_0)^2));
        disp("Solution overkill calculée")
    else % autres solutions
        meth_rect(i-1) = sum(val_fct_integrale) * dt_int;
        meth_trapz(i-1) = trapz(flip(t_p), val_fct_integrale);
    end 
end

% Calcul de la température (eq 10)
T_trapz = 1/m*(-1+sqrt(2*m*meth_trapz + (1+m*T_0)^2));
e_trapz = abs(T_trapz - T_overkill)/T_overkill;
T_rect = 1/m*(-1+sqrt(2*m*meth_rect + (1+m*T_0)^2));
e_rect = abs(T_rect - T_overkill)/T_overkill;


%% Affichage
loglog(vec_dt_int(2:end), e_trapz, ".")
hold on
loglog(vec_dt_int(2:end), e_rect, ".")

yline(0.05, '--')
xlabel("\delta t")
legend("Trapèzes", "Rectangles")
ylabel("erreur relative sur T")







