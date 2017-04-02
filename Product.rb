require "Nokogiri"
require "open-uri"
require "openssl"

require_relative "./Page"

class Product

  attr_accessor :url, :code, :name, :price, :status, :description, :last_sync, :image

  def initialize(url)
    @url = url
    @code = ""
    @name = ""
    @price = 0.0
    # @superproduct = nil
    @status = ""
    @description = ""
    @last_sync = ""
    @image = ""

    # sync product first time
    self.sync_product
  end

  # sync product
  # return true if sync successful
  # return false if anything else
  def sync_product
    begin
      # OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
      page = Nokogiri::HTML(open(@url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))

      # It's a product or They are product. (many subproduct)
      if page.css(".subproductItem").any?
        @price = -1.0
        @status = "superproduct"
      else
        @price = get_product_price(page)
        @status = get_product_status(page)
      end
      @code = get_product_code(page)
      @name = get_product_name(page)
      @description = get_product_description(page)
      @last_sync = Time.now
      @image = get_product_image(page)

      return true
    rescue OpenURI::HTTPError => e
      @status = e.to_s
      return "error: #{e}"
      # if e.message == '404 Not Found'
      #   return '404'
      # else
      #   return 'error'
      # end
    end
  end

  private
    def get_product_code(page)
      code = page.css(".productDataBlock .codeTR .bodyTD").text
      code = page.css(".codeTR .bodyTD").text if code.empty?
      return code.empty? ? "Not have code" : code
    end

    def get_product_name(page)
      name = page.css(".productHeaderBlock .headerText").text
      name = page.css(".subproductHeader .headerText").text if name.empty?
      return name
    end

    def get_product_price(page)
      cost_price = page.css(".priceTR .bodyTD").text
      return cost_price.split(" ")[0].to_f
    end

    def get_product_status(page)
      if page.css(".typeTR").any?
        return "in_stock" if page.css(".typeTR .bodyTD").text == "พร้อมส่ง"
      elsif page.css(".product_soldout").any? or page.css(".subproduct_soldout").any?
        return "out_stock"
      end
      return "not_found"
    end

    def get_product_description(page)
      return page.css("#detail").to_html
    end

    def get_product_image(page)
      image = page.css(".productPhoto .productImage")
      image = page.css(".subproductImage") if image.empty?
      return image.attr("src").to_s
    end

end

=begin
products.each do |name, url|
  product = Product.new(url)
  puts product.sync_product
  puts name
  puts product.code
  # puts product.name
  puts product.price
  puts product.status
  # puts product.description
  puts product.last_sync
  puts product.image
  puts '-------------------'
end
=end
