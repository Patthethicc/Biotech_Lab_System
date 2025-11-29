package com.biotech.lis.Service;

import java.util.List;
import org.springframework.stereotype.Service;
import com.biotech.lis.Entity.Customer;
import com.biotech.lis.Repository.CustomerRepository;

@Service
public class CustomerService {
    private final CustomerRepository customerRepository;

    public CustomerService(CustomerRepository customerRepository) {
        this.customerRepository = customerRepository;
    }

    public Customer addCustomer(Customer customer) {
        return customerRepository.save(customer);
    }

    public List<Customer> getCustomers() {
        return customerRepository.findAll();
    }

    public Customer getCustomerById(Integer id) {
        return customerRepository.findById(id).orElse(null);
    }

    public Customer updateCustomer(Customer customer) {
        Customer existingCustomer = customerRepository.findById(customer.getCustomerId()).orElse(null);
        if (existingCustomer != null) {
            existingCustomer.setName(customer.getName());
            existingCustomer.setAddress(customer.getAddress());
            existingCustomer.setSalesRepresentative(customer.getSalesRepresentative());
            return customerRepository.save(existingCustomer);
        }
        return null;
    }

    public void deleteCustomer(Integer id) {
        customerRepository.deleteById(id);
    }

    public boolean customerExists(String name) {
        return customerRepository.existsByName(name);
    }
}
