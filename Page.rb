class Page

  def initialize
    # array of products
    @products = []
    @head = "
      <head>
        <meta charset='utf-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1'>
        <script type='text/javascript' src='http://cdnjs.cloudflare.com/ajax/libs/jquery/2.0.3/jquery.min.js'></script>
        <script type='text/javascript' src='http://netdna.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js'></script>
        <link href='http://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.3.0/css/font-awesome.min.css'
        rel='stylesheet' type='text/css'>
        <link href='http://pingendo.github.io/pingendo-bootstrap/themes/default/bootstrap.css'
        rel='stylesheet' type='text/css'>
      </head>
    "
    @table = ""
    @body = ""

    self.gen_table
    self.gen_body
  end

  def add_product(product)
    @products.push(product)
  end

  def write_file(filename)
    file = File.new(filename, "w")

    if file
      self.gen_table
      self.gen_body
      html = "
        <html>
          #{@head}
          #{@body}
        </html>
      "
      file.syswrite(html)
      return true
    else
      return false
    end
  end

  def gen_table
    row = ''
    @products.each_with_index { |product, index|
      color = 'black'
      color = 'green' if product.status == "in_stock"
      color = "red" if product.status == "out_stock"

      row += '<tr>'
      row += "<td>#{index}</td>"
      row += "<td><img src='#{product.image}' class='img-responsive' style='width: 50px;'></td>"
      row += "<td>#{product.name}</td>"
      row += "<td>#{product.code}</td>"
      row += "<td>#{product.price}</td>"
      row += "<td style='color:white; background-color:#{color};'>#{product.status}</td>"
      row += "<td>#{product.last_sync}</td>"
      row += "<td><a href='#{product.url}' target='_blank'>Link</a></td>"
      row += '</tr>'
    }
    @table = "
            <table class='table table-hover table-bordered'>
              <tbody>
                #{row}
              </tbody>
              <thead>
                <tr>
                  <th>#</th>
                  <th>Image</th>
                  <th>Name</th>
                  <th>Code</th>
                  <th>Price</th>
                  <th>Status</th>
                  <th>Last Sync</th>
                  <th>URL</th>
                </tr>
              </thead>
            </table>
    "
  end

  def gen_body
    @body = "
      <body>
        <div class='section'>
          <div class='container'>
            <div class='row'>
              <div class='col-md-12'>
                #{@table}
              </div>
            </div>
          </div>
        </div>
      </body>
    "
  end

end
