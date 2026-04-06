module StocksHelper
  STOCK_META = {
    "AAPL"  => { url: "https://www.apple.com",                logo: "apple.com" },
    "MSFT"  => { url: "https://www.microsoft.com",            logo: "microsoft.com" },
    "GOOGL" => { url: "https://abc.xyz",                      logo: "google.com" },
    "AMZN"  => { url: "https://www.amazon.com",               logo: "amazon.com" },
    "NVDA"  => { url: "https://www.nvidia.com",               logo: "nvidia.com" },
    "TSLA"  => { url: "https://www.tesla.com",                logo: "tesla.com" },
    "META"  => { url: "https://about.meta.com",               logo: "meta.com" },
    "IBM"   => { url: "https://www.ibm.com",                  logo: "ibm.com" },
    "JPM"   => { url: "https://www.jpmorganchase.com",        logo: "jpmorganchase.com" },
    "V"     => { url: "https://www.visa.com",                 logo: "visa.com" },
    "JNJ"   => { url: "https://www.jnj.com",                  logo: "jnj.com" },
    "UNH"   => { url: "https://www.unitedhealthgroup.com",    logo: "unitedhealthgroup.com" },
    "WMT"   => { url: "https://www.walmart.com",              logo: "walmart.com" },
    "PG"    => { url: "https://www.pg.com",                   logo: "pg.com" },
    "HD"    => { url: "https://www.homedepot.com",            logo: "homedepot.com" },
    "MA"    => { url: "https://www.mastercard.com",           logo: "mastercard.com" },
    "BAC"   => { url: "https://www.bankofamerica.com",        logo: "bankofamerica.com" },
    "XOM"   => { url: "https://www.exxonmobil.com",           logo: "exxonmobil.com" },
    "CVX"   => { url: "https://www.chevron.com",              logo: "chevron.com" },
    "KO"    => { url: "https://www.coca-colacompany.com",     logo: "coca-colacompany.com" },
    "COST"  => { url: "https://www.costco.com",               logo: "costco.com" },
    "PEP"   => { url: "https://www.pepsico.com",              logo: "pepsico.com" },
    "MCD"   => { url: "https://www.mcdonalds.com",            logo: "mcdonalds.com" },
    "CRM"   => { url: "https://www.salesforce.com",           logo: "salesforce.com" },
    "AMD"   => { url: "https://www.amd.com",                  logo: "amd.com" },
    "NFLX"  => { url: "https://www.netflix.com",              logo: "netflix.com" },
    "NKE"   => { url: "https://www.nike.com",                 logo: "nike.com" },
    "DIS"   => { url: "https://www.thewaltdisneycompany.com", logo: "thewaltdisneycompany.com" },
    "INTC"  => { url: "https://www.intel.com",                logo: "intel.com" },
    "SBUX"  => { url: "https://www.starbucks.com",            logo: "starbucks.com" },
  }.freeze

  def stock_logo_url(ticker)
    domain = STOCK_META.dig(ticker, :logo)
    return nil unless domain
    "https://www.google.com/s2/favicons?domain=#{domain}&sz=64"
  end

  def stock_website_url(ticker)
    STOCK_META.dig(ticker, :url)
  end
end
