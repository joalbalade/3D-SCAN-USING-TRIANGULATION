function distance = laser_distance(img1_path, img2_path)

    % Chargement des images contenant les lignes de laser
    img1 = imread(img1_path);
    img2 = imread(img2_path);

    % Convertion des images en niveaux de gris
    img1_gray = rgb2gray(img1);
    img2_gray = rgb2gray(img2);

    % Convertion des images en images binaires en utilisant un seuil de luminosité
    img1_bw = imbinarize(img1_gray, 0.5);
    img2_bw = imbinarize(img2_gray, 0.5);

    % Extraction des propriétés des régions blanches de l'image binaire
    img1_props = regionprops(img1_bw, 'Centroid');
    img2_props = regionprops(img2_bw, 'Centroid');

    % Récupération des positions de la ligne de laser dans les deux images
    laser_pos1 = img1_props.Centroid;
    laser_pos2 = img2_props.Centroid;

    % Calcul de la distance euclidienne entre les positions de la ligne de laser dans les deux images
    distance = pdist2(laser_pos1, laser_pos2);

end
