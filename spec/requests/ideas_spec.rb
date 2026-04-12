require "rails_helper"

RSpec.describe "/ideas", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:alice) { create(:user) }
  let(:bob)   { create(:user) }
  let(:stock) { create(:stock) }

  before { sign_in alice }

  describe "GET /ideas" do
    it "renders a successful response" do
      get ideas_url
      expect(response).to be_successful
    end

    it "shows published ideas" do
      idea = create(:idea, user: bob, published_at: 1.hour.ago)
      get ideas_url
      expect(response.body).to include(idea.title)
    end

    it "does not show unpublished ideas" do
      create(:idea, user: bob, published_at: nil, title: "Draft Idea")
      get ideas_url
      expect(response.body).not_to include("Draft Idea")
    end

    context "with sort=popular" do
      it "sorts by likes count descending" do
        less_liked = create(:idea, title: "Less Popular", published_at: 2.hours.ago)
        more_liked = create(:idea, title: "More Popular", published_at: 1.hour.ago)
        create_list(:idea_like, 3, idea: more_liked)
        create(:idea_like, idea: less_liked)

        get ideas_url, params: { sort: "popular" }
        expect(response.body.index("More Popular")).to be < response.body.index("Less Popular")
      end
    end

    context "with tag filter" do
      it "filters ideas by tag" do
        tag = create(:idea_tag, name: "Technical Analysis")
        tagged_idea   = create(:idea, title: "Tagged", published_at: 1.hour.ago)
        _untagged_idea = create(:idea, title: "Untagged", published_at: 1.hour.ago)
        create(:idea_tagging, idea: tagged_idea, idea_tag: tag)

        get ideas_url, params: { tag: tag.id }
        expect(response.body).to include("Tagged")
        expect(response.body).not_to include("Untagged")
      end
    end

    context "with stock filter" do
      it "filters ideas by stock" do
        create(:idea, title: "AAPL idea", stock: stock, published_at: 1.hour.ago)
        create(:idea, title: "General idea", published_at: 1.hour.ago)

        get ideas_url, params: { stock_id: stock.id }
        expect(response.body).to include("AAPL idea")
        expect(response.body).not_to include("General idea")
      end
    end
  end

  describe "GET /ideas/:id" do
    let(:idea) { create(:idea, user: bob, published_at: 1.hour.ago, views_count: 5) }

    it "renders a successful response" do
      get idea_url(idea)
      expect(response).to be_successful
    end

    it "increments the view count" do
      expect { get idea_url(idea) }.to change { idea.reload.views_count }.from(5).to(6)
    end

    it "includes the idea title and body" do
      get idea_url(idea)
      expect(response.body).to include(idea.title)
      expect(response.body).to include(idea.body.to_plain_text)
    end

    it "shows the author display name" do
      get idea_url(idea)
      expect(response.body).to include(bob.display_name)
    end
  end

  describe "GET /ideas/new" do
    it "renders a successful response" do
      get new_idea_url
      expect(response).to be_successful
    end
  end

  describe "POST /ideas" do
    let(:valid_params) do
      { idea: { title: "AAPL Breakout", body: "Analysis text here.", direction: "long", stock_id: stock.id } }
    end

    let(:invalid_params) do
      { idea: { title: "", body: "", direction: "long" } }
    end

    context "with valid parameters" do
      it "creates a new Idea" do
        expect { post ideas_url, params: valid_params }.to change(Idea, :count).by(1)
      end

      it "assigns the current user as the author" do
        post ideas_url, params: valid_params
        expect(Idea.last.user).to eq(alice)
      end

      it "sets published_at" do
        post ideas_url, params: valid_params
        expect(Idea.last.published_at).to be_present
      end

      it "redirects to the created idea" do
        post ideas_url, params: valid_params
        expect(response).to redirect_to(idea_url(Idea.last))
      end
    end

    context "with invalid parameters" do
      it "does not create an Idea" do
        expect { post ideas_url, params: invalid_params }.not_to change(Idea, :count)
      end

      it "renders a 422 response" do
        post ideas_url, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /ideas/:id" do
    context "as the author" do
      let!(:idea) { create(:idea, user: alice) }

      it "destroys the idea" do
        expect { delete idea_url(idea) }.to change(Idea, :count).by(-1)
      end

      it "redirects to ideas index" do
        delete idea_url(idea)
        expect(response).to redirect_to(ideas_url)
      end
    end

    context "as a non-author" do
      let!(:idea) { create(:idea, user: bob) }

      it "does not destroy the idea" do
        expect { delete idea_url(idea) }.not_to change(Idea, :count)
      end

      it "redirects with not authorized" do
        delete idea_url(idea)
        expect(response).to redirect_to(leagues_path)
      end
    end
  end

  describe "authentication" do
    before { sign_out alice }

    it "redirects unauthenticated users to sign in" do
      get ideas_url
      expect(response).to redirect_to(new_user_session_url)
    end
  end
end
