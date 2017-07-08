class Chef::Recipe
  include Dbag
  include KeepalivedHelper
  include NsdResourceHelper
  include OpenvpnHelper
end
