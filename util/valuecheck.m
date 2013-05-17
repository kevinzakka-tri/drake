function tf = valuecheck(val,desired_val,tol)

% VALUECHECK
%   Usage:  valuecheck(val,desired_val)

if (nargin<3) tol=1e-8; end

tf = true;

if isscalar(desired_val)
  desired_val = repmat(desired_val,size(val));
end

if ((length(size(val))~=length(size(desired_val))) || any(size(val)~=size(desired_val)))
  if (nargout>0)
    tf = false;
    warning(['Wrong size.  Expected ', mat2str(size(desired_val)),' but got ', mat2str(size(val))]);
    return;
  else
    error(['Wrong size.  Expected ', mat2str(size(desired_val)),' but got ', mat2str(size(val))]);
  end
end

if (~isequal(isnan(val(:)),isnan(desired_val(:))))
  if (nargout>0)
    tf = false;
  else
    s = 'NANs don''t match. ';
    if any(isnan(val(:)))
      val
      [a,b] = ind2sub(find(isnan(val(:))),size(val));
      s = [s,sprintf('Found NANs at \n'),sprintf('(%d,%d) ',[a;b]),sprintf('\n')];
    else
      s = [s,'val has no NANs'];
    end
    if any(isnan(desired_val(:)))
      desired_val
      [a,b] = ind2sub(size(desired_val),find(isnan(desired_val(:))));
      s = [s,sprintf('but desired_val has them at \n'), sprintf('(%d,%d)',[a;b]),sprintf('\n')];
    else
      s = [s,'but desired_val has no NANs'];
    end
%    err = desired_val-val;
%    err(abs(err)<tol)=0;
%    err=sparse(err)
    
    error(s);
  end
end

if (any(abs(val(:)-desired_val(:))>tol))
  if (nargout>0)
    tf = false;
%    warning(['Values don''t match.  Expected ', mat2str(desired_val), ' but got ', mat2str(val)]);
  else
    if (ndims(val)<=2 && length(val)<=6)
      % clean before printing
      desired_val(abs(desired_val)<tol/2)=0;
      val(abs(val)<tol/2)=0;
      error('Values don''t match.  Expected \n%s\n but got \n%s', mat2str(desired_val), mat2str(val));
    else
      err = desired_val-val;
      s = size(desired_val);
      % print sparse-matrix-like format, but support ND arrays:
      ind=find(abs(err(:))>tol);
      a = cell(1,length(s));
      [a{:}] = ind2sub(s,ind);
      errstr = '';
      for i=1:numel(ind)
        b = cellfun(@(b) b(i),a);
        indstr = ['(',sprintf('%d,',b(1:end-1)), sprintf('%d)',b(end))];
        errstr = [errstr, sprintf('%10s %12f %15f\n',indstr,val(ind(i)),desired_val(ind(i)))];
      end
      error('Values don''t match.\n    Index       Value       Desired Value\n   -------     --------    ---------------\n%s', errstr);
      
    end
  end
end


