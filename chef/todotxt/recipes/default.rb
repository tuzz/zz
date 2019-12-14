package "todo-txt"

directory "create todotxt add-ons directory" do
  path ZZ::Path.todotxt_add_ons
  mode "700"
  recursive true
end

cookbook_file "todo-txt config" do
  source "config"
  path ZZ::Path.todotxt_config
end

cookbook_file "todo-txt command" do
  source "command"
  path ZZ::Path.todotxt_command
  mode "755"
end
