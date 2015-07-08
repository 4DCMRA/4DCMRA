%Jianing
function mask_output = write_mask_192short_hull(im)

% save_fname = strcat(folder_name,'mask/');
% mkdir(save_fname);
mask_output = zeros(192,192,192);
skip = 10;
for ii = skip:skip:190
    b = nmlz(im(:,:,ii));
    wr = roipoly(squeeze(b));
    for n = max(1,ii-skip+1):min(ii+skip,192)   
        mask_output(:,:,n) = wr;
    end
end

[xx,yy,zz] = meshgrid(1:192,1:192,1:192);
xx = xx(:);
yy = yy(:);
zz = zz(:);
xx = xx(mask_output(:)>0);
yy = yy(mask_output(:)>0);
zz = zz(mask_output(:)>0);
%
[K,v] = convhulln([xx,yy,zz]);
% figure,trisurf(K,xx,yy,zz),axis('equal')
%
test_hull = zeros(192,192,192);
for ii_facet = 1:size(K,1) %for every facet of the hull
    for jj_vertex = 1:size(K,2) %3 vertices on each facet
        test_hull(yy(K(ii_facet,jj_vertex)),xx(K(ii_facet,jj_vertex)),zz(K(ii_facet,jj_vertex))) = 1;
    end
end

meshXYZ = zeros(size(K,1),3,3); %coordinates of the 3 vertices for all facets
for ii_facet = 1:size(K,1) %for every facet
    for jj_vertex = 1:3 %3 vertices on each facet
        meshXYZ(ii_facet,2,jj_vertex) = xx(K(ii_facet,jj_vertex));
        meshXYZ(ii_facet,1,jj_vertex) = yy(K(ii_facet,jj_vertex));
        meshXYZ(ii_facet,3,jj_vertex) = zz(K(ii_facet,jj_vertex));
    end
end
[mask_output] = VOXELISE(1:192,1:192,1:192,meshXYZ);
mask_output = imdilate(mask_output,ones(10,10,10));
mask_output = imerode(mask_output,ones(10,10,10));