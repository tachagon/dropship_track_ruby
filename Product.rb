require "Nokogiri"
require "open-uri"
require "openssl"

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

# a1 = Product.new('https://www.dropshoppingthai.com/product/2969/%E0%B9%80%E0%B8%81%E0%B8%A5%E0%B8%B5%E0%B8%A2%E0%B8%A7%E0%B8%96%E0%B8%99%E0%B8%AD%E0%B8%A1%E0%B8%AA%E0%B8%B2%E0%B8%A2%E0%B8%8A%E0%B8%B2%E0%B8%A3%E0%B9%8C%E0%B8%95')
# puts a1.sync_product
# puts a1.code

products = {
  "เกลียวถนอมสายชาร์ต": "https://www.dropshoppingthai.com/product/2969/%E0%B9%80%E0%B8%81%E0%B8%A5%E0%B8%B5%E0%B8%A2%E0%B8%A7%E0%B8%96%E0%B8%99%E0%B8%AD%E0%B8%A1%E0%B8%AA%E0%B8%B2%E0%B8%A2%E0%B8%8A%E0%B8%B2%E0%B8%A3%E0%B9%8C%E0%B8%95",
  "ชุดถนอมสายชาร์จ คุมะ แบบที่3": "https://www.dropshoppingthai.com/product/10502/%E0%B8%8A%E0%B8%B8%E0%B8%94%E0%B8%96%E0%B8%99%E0%B8%AD%E0%B8%A1%E0%B8%AA%E0%B8%B2%E0%B8%A2%E0%B8%8A%E0%B8%B2%E0%B8%A3%E0%B9%8C%E0%B8%88-%E0%B8%84%E0%B8%B8%E0%B8%A1%E0%B8%B0-%E0%B9%81%E0%B8%9A%E0%B8%9A%E0%B8%97%E0%B8%B5%E0%B9%883",
  "เสียงใสกังวานกิ๊ง! ลำโพงบลูทูธ S815 สีฟ้า": "https://www.dropshoppingthai.com/product/10503/%E0%B9%80%E0%B8%AA%E0%B8%B5%E0%B8%A2%E0%B8%87%E0%B9%83%E0%B8%AA%E0%B8%81%E0%B8%B1%E0%B8%87%E0%B8%A7%E0%B8%B2%E0%B8%99%E0%B8%81%E0%B8%B4%E0%B9%8A%E0%B8%87-%E0%B8%A5%E0%B8%B3%E0%B9%82%E0%B8%9E%E0%B8%87%E0%B8%9A%E0%B8%A5%E0%B8%B9%E0%B8%97%E0%B8%B9%E0%B8%98-s815-%E0%B8%AA%E0%B8%B5%E0%B8%9F%E0%B9%89%E0%B8%B2",
  "ไม้เซลฟี่ เสียบช่องหูฟัง สีดำ": "https://www.dropshoppingthai.com/product/8603/%E0%B9%84%E0%B8%A1%E0%B9%89%E0%B9%80%E0%B8%8B%E0%B8%A5%E0%B8%9F%E0%B8%B5%E0%B9%88-%E0%B9%80%E0%B8%AA%E0%B8%B5%E0%B8%A2%E0%B8%9A%E0%B8%8A%E0%B9%88%E0%B8%AD%E0%B8%87%E0%B8%AB%E0%B8%B9%E0%B8%9F%E0%B8%B1%E0%B8%87-%E0%B8%AA%E0%B8%B5%E0%B8%94%E0%B8%B3",
}

products.each do |name, url|
  product = Product.new(url)
  puts product.sync_product
  puts product.code
  puts product.name
  puts product.price
  puts product.status
  # puts product.description
  puts product.last_sync
  puts product.image
  puts '-------------------'
end
