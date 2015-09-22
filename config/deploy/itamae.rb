task :apply do
  on roles(:all) do
    execute :echo, 'hello'
  end
end
before :apply, :deploy
