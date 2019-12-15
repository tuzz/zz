package "todo-txt"

cookbook_file "todo-txt config" do
  source "config"
  path ZZ::Path.todotxt_config
end

cookbook_file "todo-txt command" do
  source "command"
  path ZZ::Path.todotxt_command
  mode "755"
end

# https://github.com/mgarrido/todo.txt-cli/tree/note/todo.actions.d
remote_directory "copy todotxt add-ons" do
  source "add_ons"
  path ZZ::Path.todotxt_add_ons
  files_mode "755"
end

