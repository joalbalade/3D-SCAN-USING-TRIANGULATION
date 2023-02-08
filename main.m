clear all, close all

%% Etalonnage

laser_distance('calibration1.jpg', 'calibration2.jpg');

%% Réalisation du nuage de points

% Chargement des 63 images
images = cell(1, 63);
for i = 1:63
    images{i} = imread(sprintf('tole%d.jpg', i));
    images{i} = imrotate(images{i}, -90);
    images{i} = imgaussfilt(images{i},0.5);
    images{i}(:,:,1) = medfilt2(images{i}(:,:,1), [11 11]);
    images{i}(:,:,2) = medfilt2(images{i}(:,:,2), [3 11]);
    images{i}(:,:,3) = medfilt2(images{i}(:,:,3), [11 11]);
end

% Conversion en HSV
hsv_images = cell(1, 63);
for i = 1:63
    hsv_images{i} = rgb2hsv(images{i});
    images{i}(:,:,1) = medfilt2(images{i}(:,:,1), [3 11]);
    images{i}(:,:,2) = medfilt2(images{i}(:,:,2), [11 11]);
    images{i}(:,:,3) = medfilt2(images{i}(:,:,3), [11 11]);
end

% Extraction la couche de teinte (H)
h_images = cell(1, 63);
for i = 1:63
    h_images{i} = hsv_images{i}(:, :, 1);
    h_images{i} = medfilt2(h_images{i}, [1 3]);
end

% Appliquation d'un seuil pour détecter les pixels du laser
% Ces seuils sont à ajuster en fonctions des résultats d'extraction de la
% couche H
threshold_min = 0.35; 
threshold_max = 0.45;
laser_images = cell(1, 63);
for i = 1:63
    for j=1:size(h_images{1},1)
        for k=1:size(h_images{1},2)
            if (h_images{i}(j,k) > threshold_min) && (h_images{i}(j,k) < threshold_max)
                laser_images{i}(j,k) = h_images{i}(j,k);
            end
        end
    end
end

for i=1:63
    laser_images{i} = medfilt2(laser_images{i}, [3 11]);
end

% Recherche des coordonnées des pixels du laser dans chaque image
laser_coords = cell(1, 63);
for i = 1:63
    [y, x] = find(laser_images{i});
    laser_coords{i} = [x, -y];
end

% Affichage du nuage de points à l'aide des coordonnées récupérées
figure(1)
h = ones(length(laser_coords{1}(:,1)),1);
offset = 5; %pas d'avancement de 5 mm entre chacunes des images
scatter3(laser_coords{1}(:,1), h, laser_coords{1}(:,2),'b.'), grid on, hold on
for i=1:63
    % h et h1 servent à modéliser l'avancement linéaire de notre caméra et
    % de notre laser suivant l'axe Y
    h = ones(length(laser_coords{i}(:,1)),1);
    h1 = (h+i)*offset;
    figure(1), hold on,
    scatter3(laser_coords{i}(:,1), h1, laser_coords{i}(:,2),'b.'), grid on, hold on
end

% Suppression des points aberrants contenus dans le nuage de points
% précédent
z_max = -615;
z_min = -699;
for i = 1:63
    points_aberrants = [];
    for j = 1:length(laser_coords{i}(:,2))
        if laser_coords{i}(j,2) > z_max || laser_coords{i}(j,2) < z_min
            points_aberrants = [points_aberrants, j];
        end
    end
    laser_coords{i}(points_aberrants,:) = [];
end

% Stockage des points du nuage dans un tableau
points = [];
for i=1:63
    x = laser_coords{i}(:,1);
    y = laser_coords{i}(:,2);
    h = ones(length(x),1);
    h1 = (h+i)*offset;
    temp = [x,y,h1];
    points = [points;temp];
end

% Affichage du nuage de points filtré
figure(2)
scatter3(points(:,1), points(:,3), points(:,2),'b.'), grid on
xlabel('Axe X');
ylabel('Axe Y');
zlabel('Axe Z');

%Distance Euclidienne calculée durant l'étalonnage
ratio = ans;

% Prise en compte de cette distance pour remettre notre nuage de points à
% la bonne échelle
reals_x = (20/ratio)*points(:,1);
reals_y = (20/ratio)*points(:,3);
reals_z = (20/ratio)*points(:,2);

% Affichage du nuage de points final
figure(3)
scatter3(reals_x, reals_y, reals_z,'b.'), grid on
xlabel('Axe X');
ylabel('Axe Y');
zlabel('Axe Z');

%% Stockage des coordonnées dans un fichier texte pour un import sous Catia

for i=1:63
    dlmwrite('points.txt', points, '-append', 'delimiter', '\t', 'precision', 6);
end