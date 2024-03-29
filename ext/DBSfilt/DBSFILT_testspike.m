% [dbs_induced,n,h]=DBSFILT_testspike(Fs,FdbsL,FdbsR,nmax,eps,display)
% -----------------------------------------------------------
%
% Check if the detected spike at the frequency Fs follow the rule :
%
%                         Fs=h.Fdbs/n
%
%                where : h is a positive integer (+-eps)
%                and   : n is a positive integer<nmax
%
% INPUTS :
%
%  -Fs :       Detected spike frequency
%  -FdbsL :    Left Deep Brain Stimulation Frequency
%  -FdbsR :    Right Deep Brain Stimulation Frequency
%  -nmax :     Maximum sub-multiple of the DBS frequency.
%  -eps :      Tolerance for h positive integer
%  -display :  Display results in the command window if not null.
%
% OUTPUTS :
%
%  -dbs_induced :    1 if can be considered as a DBS aliased frequency. 0 otherwise.
%  -n:               Sub-multiple of the DBS frequency, for the fondamental of the aliased frequency. -1 if not dbs induced.
%  -h:               Harmonic of the aliased frequency. -1 if not dbs induced.
%
% USAGES :
%
%  [dbs_induced,n,h]=DBSFILT_testspike(Fs,FdbsL,FdbsR,nmax,eps,display)
%  [dbs_induced,n,h]=DBSFILT_testspike(Fs,FdbsL,FdbsR,nmax,eps)
%
% -----------------------------------------------------------

%
% Author : G. Lio
% Centre de Neurosciences Cognitives, CNRS UMR 5229, Lyon, France
% & Hospice civils de Lyon, France
% v1.0 September 2012
% v1.1 December 2012 - correction for n.
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2012 Guillaume Lio, guillaume.lio@isc.cnrs.fr
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [dbs_induced,n,h]=DBSFILT_testspike(Fs,FdbsL,FdbsR,nmax,eps,display)

if nargin<5 || nargin>6
    help testspike
    return
elseif nargin==5
    display=0;
end


dbs_induced=1;

if(FdbsL==FdbsR)
    Fdbs=FdbsL;
    
    ratio=Fdbs/Fs;
    stop=1;
    n=0;
    while stop>eps
        n=n+1;
        if(n==nmax)
            n=-1;
            h=-1;
            dbs_induced=0;
            stop=-1;
        else
            %h1=(2^n)/ratio;
            h1=(n)/ratio;
            h=round(h1);
            stop=abs(h1-h);
            %fprintf('n=%d h=%d - stop=%g\n',n,h,stop);
        end
        
    end
    
    if (display && dbs_induced==1 && Fs > 2*Fdbs)
        %keyboard
    elseif (display && dbs_induced==1)
        fprintf('[testspike] >> n=%d h=%d - DBS induced=%d (Freq = %.2f)\n',n,h,dbs_induced, Fs/ratio);
    end
    
else
    
    ratioL=FdbsL/Fs;
    ratioR=FdbsR/Fs;
    
    stop=1;
    n=0;
    while stop>eps
        n=n+1;
        if(n==nmax)
            n=-1;
            h=-1;
            dbs_induced=0;
            stop=-1;
        else
            %h1L=(2^n)/ratioL;
            %h1R=(2^n)/ratioR;
            h1L=(n)/ratioL;
            h1R=(n)/ratioR;
            hL=round(h1L);
            hR=round(h1R);
            stop=min(abs(h1L-hL),abs(h1R-hL));
            if(abs(h1L-hL)<abs(h1R-hL))
                h=hL;
            else
                h=hR;
            end
            %fprintf('n=%d h=%d - stop=%g\n',n,h,stop);
        end
        
    end
    
    if(display)
        fprintf('[testspike] >> n=%d h=%d - DBS induced=%d\n',n,h,dbs_induced);
    end
    
end