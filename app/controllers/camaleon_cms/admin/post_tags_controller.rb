class CamaleonCms::Admin::PostTagsController < CamaleonCms::AdminController
  add_breadcrumb I18n.t("camaleon_cms.admin.sidebar.contents")
  before_action :set_post_type
  before_action :set_post_tag, only: ['show','edit','update','destroy']

  def index
    @post_tags = @post_type.post_tags
    args = {post_type: @post_type}; hooks_run("before_list_post_tags", args)
    @post_tags = @post_tags.paginate(:page => params[:page], :per_page => current_site.admin_per_page)
  end

  # render post tag view
  def show
    args = {post_tag: @post_tag, post_type: @post_type}; hooks_run("before_show_post_tag", args)
  end

  # render post tag edit form
  def edit
    add_breadcrumb t("camaleon_cms.admin.button.edit")
  end

  # save changes of a post tag
  def update
    args = {post_tag: @post_tag, post_type: @post_type}; hooks_run("before_update_post_tag", args)
    if @post_tag.update(params.require(:post_tag).permit!)
      @post_tag.set_options(params[:meta]) if params[:meta].present?
      @post_tag.set_field_values(params[:field_options])
      hooks_run("after_update_post_tag", args)
      flash[:notice] = t('camaleon_cms.admin.post_type.message.updated')
      redirect_to action: :index
    else
      render edit
    end
  end

  # render post tag create form
  def create
    @post_tag = @post_type.post_tags.new(params.require(:post_tag).permit!)
    args = {post_tag: @post_tag, post_type: @post_type}; hooks_run("before_create_post_tag", args)
    if @post_tag.save
      @post_tag.set_options(params[:meta]) if params[:meta].present?
      @post_tag.set_field_values(params[:field_options])
      hooks_run("after_create_post_tag", args)
      flash[:notice] = t('camaleon_cms.admin.post_type.message.created')
      redirect_to action: :index
    else
      render 'edit'
    end
  end

  # destroy a post tag
  def destroy
    args = {post_tag: @post_tag, post_type: @post_type}; hooks_run("before_destroy_post_tag", args)
    flash[:notice] = t('camaleon_cms.admin.post_type.message.deleted') if @post_tag.destroy
    redirect_to action: :index
  end

  # render a json of post tags of a post type
  def list
    @post_tags = @post_type.post_tags.pluck("name")
    render json: @post_tags
  end

  private

  def set_post_type
    @post_type = current_site.post_types.find_by_id(params[:post_type_id]).decorate
    authorize! :post_tags, @post_type
    add_breadcrumb @post_type.the_title, @post_type.the_admin_url
    add_breadcrumb t("camaleon_cms.admin.post_type.post_tags"), url_for({action: :index})
  end

  def set_post_tag
    begin
      @post_tag = @post_type.post_tags.find_by_id(params[:id])
    rescue
      flash[:error] = t('camaleon_cms.admin.post_type.message.error')
      redirect_to cama_admin_path
    end
  end
end
