//
//  ViewController.swift
//  Cryptocurrency Management
//
//  Created by Yuki Tsukada on 2021/01/17, advised by Daiki Sugihara.
//
import UIKit
import Charts

private enum State {
    case closed
    case open
}
extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

class ViewController: UIViewController {
    let addCurrencyButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle("Add Currency", for: .normal)
        bt.setTitleColor(UIColor(hex: "#426DDC"), for: .normal)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        bt.frame.size.height = 36
        bt.layer.cornerRadius = bt.frame.height * 0.3
        bt.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        bt.backgroundColor = UIColor(hex: "#212A6B", alpha: 1.0)
        bt.addTarget(self, action: #selector(addCurrencyButtonTapped(_:)), for: .touchUpInside)
        return bt
    }()
    let tableViewSwitchButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle("＝", for: .normal)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        bt.setTitleColor(UIColor(hex: "#FF2E63"), for: .normal)
        bt.frame.size.height = 48
        bt.layer.cornerRadius = bt.frame.height * 0.5
        bt.backgroundColor = UIColor(hex: "#212A6B")
        bt.addTarget(self, action: #selector(tableViewSwitchButtonTapped(_:)), for: .touchUpInside)
        return bt
    }()
    let rootHeaderSV: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .fill
        sv.spacing = 10
        return sv
    }()
    let spinner = UIActivityIndicatorView(style: .large)
    let chartContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    let orderBookContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(hex: "#010A43")
        return v
    }()
    let orderBookContainerHeaderSV: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 10
        return sv
    }()
    let orderBookLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Order Book"
        lb.textAlignment = .center
        lb.textColor = UIColor(hex: "#858EC5")
        lb.font = UIFont.systemFont(ofSize: 24)
        return lb
    }()
    let orderBookContainerHeaderLowerSV: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        sv.spacing = 10
        return sv
    }()
    let askLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Ask"
        lb.textAlignment = .center
        lb.textColor = UIColor(hex: "#858EC5")
        return lb
    }()
    let priceLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Price"
        lb.textAlignment = .center
        lb.textColor = UIColor(hex: "#858EC5")
        return lb
    }()
    let bidLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Bid"
        lb.textAlignment = .center
        lb.textColor = UIColor(hex: "#858EC5")
        return lb
    }()
    let orderBookChartContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    let orderBookScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    let headerWrapper: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    let tableHeaderSV: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 10
        return sv
    }()
    let tableHeaderRightSV: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .fill
        sv.spacing = 10
        return sv
    }()
    let editButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setTitle("Edit", for: .normal)
        bt.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        bt.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)
        return bt
    }()
    let deleteButton: UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.setImage(UIImage(systemName: "trash"), for: .normal)
        bt.tintColor = .red
        bt.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        return bt
    }()
    let allCurrencyLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "All Currencies"
        lb.textColor = UIColor(hex: "#FFFFFF")
        return lb
    }()
    let cellId = "currencyCellId"
    private var currentState: State = .closed
    private lazy var popupView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: "#10194E")
        view.layer.cornerRadius = 20
        return view
    }()
    let currencyTableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .gray
        return tv
    }()
    var registeredCurrencies: [Cryptocurrency] =
            [Cryptocurrency(name: "Bitcoin", price: 45497.94),
             Cryptocurrency(name: "Ethereum", price: 1408.84),
             Cryptocurrency(name: "Ripple", price: 0.301),
             Cryptocurrency(name: "Litecoin", price: 180.64),
             Cryptocurrency(name: "Bitcoin Cash", price: 476.05),
             Cryptocurrency(name: "Stellar", price: 0.29),
             Cryptocurrency(name: "EOS", price: 2.73),
             Cryptocurrency(name: "Tezos", price: 2.75),
             Cryptocurrency(name: "Dash", price: 113.29),
             Cryptocurrency(name: "Ethereum Classic", price: 7.75),
             Cryptocurrency(name: "Bitcoin", price: 45497.94),
             Cryptocurrency(name: "Ethereum", price: 1408.84),
             Cryptocurrency(name: "Ripple", price: 0.301),
             Cryptocurrency(name: "Litecoin", price: 180.64),
             Cryptocurrency(name: "Bitcoin Cash", price: 476.05),
             Cryptocurrency(name: "Stellar", price: 0.29),
             Cryptocurrency(name: "EOS", price: 2.73),
             Cryptocurrency(name: "Tezos", price: 2.75),
             Cryptocurrency(name: "Dash", price: 113.29),
             Cryptocurrency(name: "Ethereum Classic", price: 7.75),
             Cryptocurrency(name: "Bitcoin", price: 45497.94),
             Cryptocurrency(name: "Ethereum", price: 1408.84),
             Cryptocurrency(name: "Ripple", price: 0.301),
             Cryptocurrency(name: "Litecoin", price: 180.64),
             Cryptocurrency(name: "Bitcoin Cash", price: 476.05),
             Cryptocurrency(name: "Stellar", price: 0.29),
             Cryptocurrency(name: "EOS", price: 2.73),
             Cryptocurrency(name: "Tezos", price: 2.75),
             Cryptocurrency(name: "Dash", price: 113.29),
             Cryptocurrency(name: "Ethereum Classic", price: 7.75)]
    var allowDissmissModal = true
    var selectedRows: [Int] = []
    var registeredOrders: [OrderBook] = [
        OrderBook(currencyName: "Bitcoin", price: 4050.0, amount: 100, orderBookType: OrderBook.OrderBookType.bid),
        OrderBook(currencyName: "Bitcoin", price: 4100.0, amount: 200, orderBookType: OrderBook.OrderBookType.bid),
        OrderBook(currencyName: "Bitcoin", price: 4150.0, amount: 300, orderBookType: OrderBook.OrderBookType.bid),
        OrderBook(currencyName: "Bitcoin", price: 4200.0, amount: 400, orderBookType: OrderBook.OrderBookType.bid),
        OrderBook(currencyName: "Bitcoin", price: 4250.0, amount: 500, orderBookType: OrderBook.OrderBookType.bid),
        OrderBook(currencyName: "Bitcoin", price: 4300.0, amount: 600, orderBookType: OrderBook.OrderBookType.bid),
        OrderBook(currencyName: "Bitcoin", price: 4350.0, amount: 700, orderBookType: OrderBook.OrderBookType.bid),
        OrderBook(currencyName: "Bitcoin", price: 4400.0, amount: 800, orderBookType: OrderBook.OrderBookType.bid),
        OrderBook(currencyName: "Bitcoin", price: 4450.0, amount: 900, orderBookType: OrderBook.OrderBookType.bid),
        OrderBook(currencyName: "Bitcoin", price: 4500.0, amount: 1000, orderBookType: OrderBook.OrderBookType.bid),
        OrderBook(currencyName: "Bitcoin", price: 4550.0, amount: 1000, orderBookType: OrderBook.OrderBookType.ask),
        OrderBook(currencyName: "Bitcoin", price: 4600.0, amount: 900, orderBookType: OrderBook.OrderBookType.ask),
        OrderBook(currencyName: "Bitcoin", price: 4650.0, amount: 800, orderBookType: OrderBook.OrderBookType.ask),
        OrderBook(currencyName: "Bitcoin", price: 4700.0, amount: 700, orderBookType: OrderBook.OrderBookType.ask),
        OrderBook(currencyName: "Bitcoin", price: 4750.0, amount: 600, orderBookType: OrderBook.OrderBookType.ask),
        OrderBook(currencyName: "Bitcoin", price: 4800.0, amount: 500, orderBookType: OrderBook.OrderBookType.ask),
        OrderBook(currencyName: "Bitcoin", price: 4850.0, amount: 400, orderBookType: OrderBook.OrderBookType.ask),
        OrderBook(currencyName: "Bitcoin", price: 4900.0, amount: 300, orderBookType: OrderBook.OrderBookType.ask),
        OrderBook(currencyName: "Bitcoin", price: 4950.0, amount: 200, orderBookType: OrderBook.OrderBookType.ask),
        OrderBook(currencyName: "Bitcoin", price: 5000.0, amount: 100, orderBookType: OrderBook.OrderBookType.ask)
    ]
    let orderBookCellSVHeight = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        orderBookCellRoop()
    }
    
    @objc func addCurrencyButtonTapped(_ sender: UIButton) {
        let nextView = AddCurrencyViewController()
        nextView.modalTransitionStyle = .coverVertical
        present(nextView, animated: true, completion: nil)
    }
    
    @objc func tableViewSwitchButtonTapped(_ sender: UIButton) {
        switchTableViewDisplay()
    }
    
    @objc func editButtonTapped(_ sender: UIButton) {
        // allow multiple selection
        currencyTableView.allowsMultipleSelection = true
        currencyTableView.allowsMultipleSelectionDuringEditing = true
        currencyTableView.setEditing(!currencyTableView.isEditing, animated: true)
        // disable modal dismissal during editing
        allowDissmissModal = !currencyTableView.isEditing
        // show delete button during editing
        deleteButton.isHidden = !currencyTableView.isEditing
        if currencyTableView.isEditing {
            editButton.setTitle("✕", for: .normal)
        } else {
            // reset the contents of selectedRows array if the user stops editing without deleting
            selectedRows.removeAll()
            editButton.setTitle("Edit", for: .normal)
        }
    }
    
    // multiple deletion
    @objc func deleteButtonTapped(_ sender: UIButton) {
        let sortedSelectedRows = selectedRows.sorted { $0 > $1 }
        for eachRow in sortedSelectedRows {
            registeredCurrencies.remove(at: eachRow)
        }
        // reset the contents of selectedRows array after deleting selected items
        selectedRows.removeAll()
        currencyTableView.reloadData()
    }
    
    private var bottomConstraint = NSLayoutConstraint()
    
    private func setupLayout() {
        view.backgroundColor = UIColor(hex: "#010A43")
        
        
        
        // spinner
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        // currencyTableView
        currencyTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        currencyTableView.delegate = self
        currencyTableView.dataSource = self
        currencyTableView.backgroundColor = UIColor(hex: "#10194E")
        
        // addSubview
        view.addSubview(rootHeaderSV)
        rootHeaderSV.addArrangedSubview(tableViewSwitchButton)
        rootHeaderSV.addArrangedSubview(addCurrencyButton)
        
        view.addSubview(chartContainer)
        chartContainer.addSubview(spinner)
        
        view.addSubview(orderBookContainer)
        orderBookContainer.addSubview(orderBookContainerHeaderSV)
        orderBookContainerHeaderSV.addArrangedSubview(orderBookLabel)
        orderBookContainerHeaderSV.addArrangedSubview(orderBookContainerHeaderLowerSV)
        orderBookContainerHeaderLowerSV.addArrangedSubview(askLabel)
        orderBookContainerHeaderLowerSV.addArrangedSubview(priceLabel)
        orderBookContainerHeaderLowerSV.addArrangedSubview(bidLabel)
        orderBookContainer.addSubview(orderBookScrollView)
        orderBookScrollView.addSubview(orderBookChartContainer)
        
        
        view.addSubview(popupView)
        popupView.addSubview(currencyTableView)
        popupView.addSubview(headerWrapper)
        headerWrapper.addSubview(tableHeaderSV)
        tableHeaderSV.addArrangedSubview(allCurrencyLabel)
        tableHeaderSV.addArrangedSubview(tableHeaderRightSV)
        tableHeaderRightSV.addArrangedSubview(deleteButton)
        tableHeaderRightSV.addArrangedSubview(editButton)
        
        deleteButton.isHidden = true
        
                
        NSLayoutConstraint.activate([
            rootHeaderSV.heightAnchor.constraint(equalToConstant: 50),
            rootHeaderSV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            rootHeaderSV.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            rootHeaderSV.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            tableViewSwitchButton.heightAnchor.constraint(equalToConstant: 48),
            tableViewSwitchButton.widthAnchor.constraint(equalToConstant: 48),
            
            addCurrencyButton.widthAnchor.constraint(equalToConstant: 140),
            
            chartContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            chartContainer.topAnchor.constraint(equalTo: rootHeaderSV.bottomAnchor, constant: 10),
            chartContainer.widthAnchor.constraint(equalTo: view.widthAnchor),
            chartContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.28),
            
            spinner.centerXAnchor.constraint(equalTo: chartContainer.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: chartContainer.centerYAnchor),
            
            orderBookContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            orderBookContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            orderBookContainer.topAnchor.constraint(equalTo: chartContainer.bottomAnchor, constant: 20),
            orderBookContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            orderBookContainerHeaderSV.leadingAnchor.constraint(equalTo: orderBookContainer.leadingAnchor),
            orderBookContainerHeaderSV.trailingAnchor.constraint(equalTo: orderBookContainer.trailingAnchor),
            orderBookContainerHeaderSV.topAnchor.constraint(equalTo: orderBookContainer.topAnchor),
            orderBookContainerHeaderSV.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.075),
            
            orderBookLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            
            orderBookContainerHeaderLowerSV.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.025),
            
            orderBookScrollView.topAnchor.constraint(equalTo: orderBookContainerHeaderSV.bottomAnchor),
            orderBookScrollView.leadingAnchor.constraint(equalTo: orderBookContainer.leadingAnchor),
            orderBookScrollView.widthAnchor.constraint(equalTo: orderBookContainer.widthAnchor),
            orderBookScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
                        
            tableHeaderSV.topAnchor.constraint(equalTo: popupView.safeAreaLayoutGuide.topAnchor, constant: 15),
            tableHeaderSV.heightAnchor.constraint(equalTo: headerWrapper.heightAnchor, multiplier: 0.7),
            
            headerWrapper.heightAnchor.constraint(equalToConstant: 50),
            headerWrapper.topAnchor.constraint(equalTo: popupView.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerWrapper.leadingAnchor.constraint(equalTo: popupView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            headerWrapper.trailingAnchor.constraint(equalTo: popupView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            tableHeaderSV.topAnchor.constraint(equalTo: headerWrapper.topAnchor),
            tableHeaderSV.bottomAnchor.constraint(equalTo: headerWrapper.bottomAnchor),
            tableHeaderSV.leadingAnchor.constraint(equalTo: headerWrapper.leadingAnchor),
            tableHeaderSV.trailingAnchor.constraint(equalTo: headerWrapper.trailingAnchor),
            
            popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2),
            popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2),
            popupView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            currencyTableView.heightAnchor.constraint(equalTo: popupView.heightAnchor, constant: -60),
            currencyTableView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor),
            currencyTableView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor),
            currencyTableView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor)
        ])
        // for switching currencyTableView position
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.size.height * 0.05)
        bottomConstraint.isActive = true
    }
    
    private func orderBookCellRoop() {
        var n = 0
        let sortedRegisteredCurrencies = registeredOrders.sorted { $1.price < $0.price }
        for order in sortedRegisteredCurrencies {
            let orderBookCellSV: UIStackView = {
                let sv = UIStackView()
                sv.translatesAutoresizingMaskIntoConstraints = false
                sv.axis = .horizontal
                sv.distribution = .fillEqually
                sv.alignment = .center
                sv.spacing = 10
                return sv
            }()
            let askAmountLabel: UILabel = {
                let lb = UILabel()
                lb.translatesAutoresizingMaskIntoConstraints = false
                if order.orderBookType == OrderBook.OrderBookType.bid {
                    lb.text = ""
                } else {
                    lb.text = "\(order.amount)"
                }
                lb.textAlignment = .center
                lb.textColor = UIColor(hex: "#858EC5")
                return lb
            }()
            let eachPriceLabel: UILabel = {
                let lb = UILabel()
                lb.translatesAutoresizingMaskIntoConstraints = false
                lb.text = "\(order.price)"
                lb.textAlignment = .center
                if order.orderBookType == OrderBook.OrderBookType.bid {
                    lb.textColor = UIColor(hex: "#1DC7AC")
                } else {
                    lb.textColor = UIColor(hex: "#FF3B30")
                }
                return lb
            }()
            let bidAmountLabel: UILabel = {
                let lb = UILabel()
                lb.translatesAutoresizingMaskIntoConstraints = false
                if order.orderBookType == OrderBook.OrderBookType.bid {
                    lb.text = "\(order.amount)"
                } else {
                    lb.text = ""
                }
                lb.textAlignment = .center
                lb.textColor = UIColor(hex: "#858EC5")
                return lb
            }()
            
            orderBookChartContainer.addSubview(orderBookCellSV)
            orderBookCellSV.addArrangedSubview(askAmountLabel)
            orderBookCellSV.addArrangedSubview(eachPriceLabel)
            orderBookCellSV.addArrangedSubview(bidAmountLabel)
            
            orderBookCellSV.heightAnchor.constraint(equalToConstant: CGFloat(orderBookCellSVHeight)).isActive = true
            orderBookCellSV.layoutIfNeeded()
            let orderBookCellSVHeightForConstraint = orderBookCellSV.frame.height
            
            
            NSLayoutConstraint.activate([
                orderBookCellSV.topAnchor.constraint(equalTo: orderBookChartContainer.topAnchor, constant: CGFloat(n) * orderBookCellSVHeightForConstraint),
                orderBookCellSV.leadingAnchor.constraint(equalTo: orderBookContainer.leadingAnchor),
                orderBookCellSV.widthAnchor.constraint(equalTo: orderBookContainer.widthAnchor)
            ])
            
            n += 1
        }
        orderBookChartContainer.frame.size.height = CGFloat(orderBookCellSVHeight * registeredOrders.count)
        orderBookChartContainer.frame.size.width = view.frame.size.width
        orderBookScrollView.frame.size.height = view.frame.size.height * 0.5
        orderBookScrollView.frame.size.width = view.frame.size.width
        orderBookScrollView.contentSize = orderBookChartContainer.bounds.size
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1 , reuseIdentifier: cellId)
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor(hex: "#192259") : UIColor(hex: "#10194E")
        cell.textLabel?.textColor = UIColor(hex: "#858EC5")
        cell.textLabel?.text = registeredCurrencies[indexPath.row].name
        cell.textLabel?.font = .boldSystemFont(ofSize: 17)
        cell.detailTextLabel?.text = "$ \(registeredCurrencies[indexPath.row].price)"
        cell.detailTextLabel?.textColor = UIColor(hex: "#1DC7AC")
        cell.imageView?.image = UIImage(named: "default")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registeredCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allowDissmissModal {
            switchTableViewDisplay()
        } else {
            selectedRows.append(indexPath.row)
        }
    }
    
    // swipe delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            registeredCurrencies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
            // for updating cell.backgroundColor
            tableView.reloadData()
        }
    }
    
    // table view modal dismissal and reappearance
    private func switchTableViewDisplay() {
        let state = currentState.opposite
        let transitionAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = self.view.frame.height * 0.95
            case .closed:
                self.bottomConstraint.constant = self.view.frame.size.height * 0.05
            }
            self.view.layoutIfNeeded()
        })
        transitionAnimator.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            }
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = self.view.frame.height * 0.95
            case .closed:
                self.bottomConstraint.constant = self.view.frame.size.height * 0.05
            }
        }
        transitionAnimator.startAnimation()
    }
}
