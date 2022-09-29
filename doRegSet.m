% topdir = '/Volumes/e$/Clinical_Specimen/';
topdir = '\\bki04\e$\Clinical_Specimen\';
A = dir(fullfile(topdir, 'M*'));
specID = {A(:).name};%{'M1_1','M2_3'};%M9_1','M10_2','M11_1','M12_1'};
% specID = {'M41_1'};
for i1 = 1%round(length(specID)/2)+1:length(specID)
    
    tic;
    he = ['\\bki04\e$\Clinical_Specimen\',specID{i1},'\HE\',specID{i1},'.ndpi'];
    ihc = ['\\bki04\e$\Clinical_Specimen\',specID{i1},'\IHC\',specID{i1},'.ndpi'];
    ifdir = ['\\bki04\e$\Clinical_Specimen\',specID{i1},'\inform_data\Component_Tiffs'];
    if_hpfs = dir(fullfile(ifdir,'*component_data.tif'));
    
    if exist(ihc,'file')
        S = strsplit(ihc,'\');
        ihc_dir = ['\',strjoin(S(1:6),'\'),'\HPFs\'];
        ihc_hpfs = dir(fullfile(ihc_dir, '*IHC.tif'));
        if length(ihc_hpfs) == length(if_hpfs)
            try
                regFullSlide(ihc,ifdir);
            catch ME
                warning(['MATLAB returned the following error identifier - ',ME.identifier]);
                warning(['MATLAB returned the following error message - ',ME.message]);
                A(i1).error = 1;
            end
%         else
%             fprintf(['Directory ',ihc_dir,' already exists with all HPFs. Delete directory and try again. \n'])
            
        end
    end
    toc;
    tic;
    if exist(he,'file')
        S = strsplit(he,'\');
        he_dir = ['\',strjoin(S(1:6),'\'),'\HPFs\'];
        he_hpfs = dir(fullfile(he_dir, '*HE.tif'));
        if length(he_hpfs) == length(if_hpfs)
            try
                regFullSlide(he,ifdir);
            catch ME
                warning(['MATLAB returned the following error identifier - ',ME.identifier]);
                warning(['MATLAB returned the following error message - ',ME.message]);
                A(i1).error = 1;
            end
%         else
%             fprintf(['Directory ',he_dir,' already exists with all HPFs. Delete directory and try again. \n'])
            
        end
    end
    toc;
end