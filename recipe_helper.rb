require 'pathname'

module RecipeHelper
  ROOT_DIR = Pathname.new(File.expand_path(__dir__))

  def include_role(name)
    path = ROOT_DIR.join('roles', *name.split('::'))
    path = path.relative_path_from(Pathname.new(@recipe.path).parent)
    include_recipe(path.to_s)
  end

  def include_cookbook(name)
    path = ROOT_DIR.join('cookbooks', *name.split('::'))
    path = path.relative_path_from(Pathname.new(@recipe.path).parent)
    include_recipe(path.to_s)
  end
end

Itamae::Recipe::EvalContext.send(:include, RecipeHelper)
