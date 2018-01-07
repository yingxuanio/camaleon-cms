class CamaleonCms::Admin::CategoriesController < CamaleonCms::AdminController
  add_breadcrumb I18n.t("camaleon_cms.admin.sidebar.contents")
  before_action :set_post_type
  before_action :set_category, only: ['show','edit','update','destroy']

  def index
    @categories = @post_type.categories
    @categories = @categories.paginate(:page => params[:page], :per_page => current_site.admin_per_page)
    hooks_run("list_category", {categories: @categories, post_type: @post_type})
  end

  def show
  end

  def edit
    add_breadcrumb t("camaleon_cms.admin.button.edit")
  end

  def update
    hooks_run("update_category", {category: @category, post_type: @post_type})

    if @category.update(params.require(:category).permit!)
      @category.set_options(params[:meta])
      @category.set_field_values(params[:field_options])
      hooks_run("updated_category", {category: @category, post_type: @post_type})
      flash[:notice] = t('camaleon_cms.admin.post_type.message.updated')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  def create
    @category = @post_type.categories.new(params.require(:category).permit!)
    if @category.save
      @category.set_options(params[:meta])
      @category.set_field_values(params[:field_options])
      flash[:notice] = t('camaleon_cms.admin.post_type.message.created')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  # return html category list used to reload categories list in post editor form
  def list
    render inline: post_type_html_inputs(@post_type, "categories", "categories" , @post_type.get_option('has_single_category', false) ? 'radio' : "checkbox" , params[:categories] || [], "categorychecklist", true )
  end

  def destroy
    flash[:notice] = t('camaleon_cms.admin.post_type.message.deleted') if @category.destroy
    redirect_to action: :index
  end

  private
  # define parent post type
  def set_post_type
    begin
      @post_type = current_site.post_types.find_by_id(params[:post_type_id]).decorate
    rescue
      flash[:error] =  t('camaleon_cms.admin.request_error_message')
      redirect_to cama_admin_path, {error: 'Error Post Type'}
    end
    add_breadcrumb @post_type.the_title, @post_type.the_admin_url
    add_breadcrumb t("camaleon_cms.admin.table.categories"), url_for({action: :index})
    authorize! :categories, @post_type
  end

  def set_category
    begin
      @category = CamaleonCms::Category.find_by_id(params[:id])
    rescue
      flash[:error] = t('camaleon_cms.admin.post_type.message.error')
      redirect_to cama_admin_path
    end
  end
end
