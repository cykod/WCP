module ApplicationHelper

  def top_links
    if myself.logged_in?
      link_to("My Account", account_url) +
        link_to("Logout", logout_url, :method => :post)
    end
  end

  def notice
    flash[:notice]
  end

end
