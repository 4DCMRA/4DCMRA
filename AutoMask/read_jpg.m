function img = read_jpg(foldername)
    save_fname = foldername;
    for n = 1:192
        if(n<10) 
            img(:,:,n) = imread(strcat(save_fname,'/00',num2str(n),'.jpeg'));
        elseif (n < 99)
            img(:,:,n) = imread(strcat(save_fname,'/0',num2str(n),'.jpeg'));
        else
            img(:,:,n) = imread(strcat(save_fname,'/',num2str(n),'.jpeg'));
        end
    end
     img = uint8(img > 128);
end