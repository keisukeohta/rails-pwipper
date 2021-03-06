class UsersController < ApplicationController

  #サインインしているユーザーしか、編集と更新、インデックスの閲覧、削除ができないようにする。
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]

  #正規のユーザーしか、編集と更新ができないようにする。
  before_action :correct_user, only: [:edit, :update]

  #index（ユーザー一覧）を定義
  #ページネーション実装のため、User.all -> User.paginate に書き換え。:pageパラメーターに基いて、データベースからひとかたまりのデータ (デフォルトでは30) を取り出す。
  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    #show.html.erbで表示したいインスタンス変数がある場合は、showアクションの中に作成する。
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    #findメソッドとdestroyメソッドを1行で書くために2つのメソッドを連結 (chain)

    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  #フォロー中のユーザー一覧アクションを定義
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])

    render 'show_follow'
    #renderを明示的に呼び出していることに注意。ここでは、作成の必要なshow_followというビューを出力している。renderで呼び出しているビューが同じである理由は、このERbはどちらの場合でもほぼ同じであり、両方の場合をカバーできるため。

  end

  #フォロワー一覧アクションを定義
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
    #renderを明示的に呼び出していることに注意
  end

private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
end