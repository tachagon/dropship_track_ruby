# import roo for work with Excel
require "roo"

require_relative "./Product"
require_relative "./Page"

def update_products_from_excel
  # create a page for present result
  page = Page.new

  # open the excel file that store products data
  xlsx = Roo::Spreadsheet.open('./input/products.xlsx')
  xlsx = Roo::Excelx.new("./input/products.xlsx")

  # find number of product for calculate percent of progress
  product_size = xlsx.last_row - xlsx.first_row + 1 - 3

  xlsx.each_with_index(
    shopee_id: 'ps_product_id',
    product_id: 'ps_sku_ref_no_parent',
    name: 'ps_product_name',
    price: 'ps_cost',
    retailPrice: 'ps_price',
    url: 'ps_url'
    ) do |hash, index|
      if index >= 3
        # create a new Product
        product = Product.new(hash[:url])
        # define product's retail price
        product.retailPrice = hash[:retailPrice]
        # sync a product for get datas
        product.sync_product
        # define product's name
        product.name = hash[:name]
        # define product's code
        product.code = hash[:product_id]
        # add a product into html page
        page.add_product(product)

        # show progress via cli
        percent = (index - 2.0) / product_size.to_f * 100.0
        puts "#{index - 2}/#{product_size} ----- #{percent.round(2)}% -----"
      end
  end

  # write information into html file
  page.write_file("./output/index.html")

  file = File.new("./output/my_product.csv", "w")
  if file
    file.syswrite(xlsx.to_csv)
    puts "SUCCESS TO WRITE CSV FILE"
  else
    puts "ERROR TO WRITE CSV FILE"
  end

  puts "SUCCESS TO UPDATE PRODUCTS FROM EXCEL"

end

def main
  update_products_from_excel

  # products = {
  #   "เกลียวถนอมสายชาร์ต": "https://www.dropshoppingthai.com/product/2969/%E0%B9%80%E0%B8%81%E0%B8%A5%E0%B8%B5%E0%B8%A2%E0%B8%A7%E0%B8%96%E0%B8%99%E0%B8%AD%E0%B8%A1%E0%B8%AA%E0%B8%B2%E0%B8%A2%E0%B8%8A%E0%B8%B2%E0%B8%A3%E0%B9%8C%E0%B8%95",
  #   "ชุดถนอมสายชาร์จ คุมะ แบบที่3": "https://www.dropshoppingthai.com/product/10502/%E0%B8%8A%E0%B8%B8%E0%B8%94%E0%B8%96%E0%B8%99%E0%B8%AD%E0%B8%A1%E0%B8%AA%E0%B8%B2%E0%B8%A2%E0%B8%8A%E0%B8%B2%E0%B8%A3%E0%B9%8C%E0%B8%88-%E0%B8%84%E0%B8%B8%E0%B8%A1%E0%B8%B0-%E0%B9%81%E0%B8%9A%E0%B8%9A%E0%B8%97%E0%B8%B5%E0%B9%883",
  #   "เสียงใสกังวานกิ๊ง! ลำโพงบลูทูธ S815 สีฟ้า": "https://www.dropshoppingthai.com/product/10503/%E0%B9%80%E0%B8%AA%E0%B8%B5%E0%B8%A2%E0%B8%87%E0%B9%83%E0%B8%AA%E0%B8%81%E0%B8%B1%E0%B8%87%E0%B8%A7%E0%B8%B2%E0%B8%99%E0%B8%81%E0%B8%B4%E0%B9%8A%E0%B8%87-%E0%B8%A5%E0%B8%B3%E0%B9%82%E0%B8%9E%E0%B8%87%E0%B8%9A%E0%B8%A5%E0%B8%B9%E0%B8%97%E0%B8%B9%E0%B8%98-s815-%E0%B8%AA%E0%B8%B5%E0%B8%9F%E0%B9%89%E0%B8%B2",
  #   "ไม้เซลฟี่ เสียบช่องหูฟัง สีดำ": "https://www.dropshoppingthai.com/product/8603/%E0%B9%84%E0%B8%A1%E0%B9%89%E0%B9%80%E0%B8%8B%E0%B8%A5%E0%B8%9F%E0%B8%B5%E0%B9%88-%E0%B9%80%E0%B8%AA%E0%B8%B5%E0%B8%A2%E0%B8%9A%E0%B8%8A%E0%B9%88%E0%B8%AD%E0%B8%87%E0%B8%AB%E0%B8%B9%E0%B8%9F%E0%B8%B1%E0%B8%87-%E0%B8%AA%E0%B8%B5%E0%B8%94%E0%B8%B3",
  # }


  # page = Page.new
  # index = 1
  # products.each { |name, url|
  #   product = Product.new(url)
  #   product.sync_product
  #   # set name by manual
  #   product.name = name
  #   page.add_product(product)

  #   percent = index.to_f / products.size.to_f * 100.0
  #   puts "#{index}/#{products.size} ----- #{percent.round(2)}% -----"
  #   index += 1
  # }
  # page.write_file("./output/index.html")

end

main
