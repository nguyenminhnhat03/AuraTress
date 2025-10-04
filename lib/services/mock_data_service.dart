import '../models/salon.dart';

class MockDataService {
  static List<Salon> getHoChiMinhSalons() {
    return [
      Salon(
        id: 'salon_nghia_001',
        name: 'Hair Salon NGHIA',
        location: 'Near Banking University, Thu Duc, Ho Chi Minh City',
        rating: 4.2,
        reviews: 156,
        priceRange: '50,000 - 150,000 VND',
        services: ['Premium Cut & Style', 'Basic Cut', 'Hair Wash'],
        distance: 1.2,
        openHours: '8:00 AM - 8:00 PM',
        phone: 'Contact via Facebook',
        description: 'Small salon specializing in beautiful, cheap haircuts for men and women, suitable for students and office workers. Friendly space, skilled workers, fast service.',
        imageUrl: 'https://via.placeholder.com/300x200?text=Hair+Salon+NGHIA',
        latitude: 10.8700,
        longitude: 106.8030,
      ),
      Salon(
        id: 'salon_1900_002',
        name: '1900 Hair Salon',
        location: '123 Nguyen Huu Canh, Binh Thanh District, Ho Chi Minh City',
        rating: 4.0,
        reviews: 203,
        priceRange: '60,000 - 200,000 VND',
        services: ['Premium Cut & Style', 'AI Color Consultation', 'Basic Styling'],
        distance: 2.1,
        openHours: '9:00 AM - 9:00 PM',
        phone: '028 3899 1900',
        description: 'Cheap salon with basic cutting and modern styling services. Praised for its cleanliness and free consultation, ideal for busy customers.',
        imageUrl: 'https://via.placeholder.com/300x200?text=1900+Hair+Salon',
        latitude: 10.8014,
        longitude: 106.7109,
      ),
      Salon(
        id: 'salon_thuy_003',
        name: 'Hair Salon Thuy',
        location: '10m Car Alley, District 3, Ho Chi Minh City',
        rating: 4.3,
        reviews: 89,
        priceRange: '40,000 - 120,000 VND',
        services: ['Premium Cut & Style', 'Hair Treatment', 'Natural Hair Care'],
        distance: 0.8,
        openHours: '8:30 AM - 7:30 PM',
        phone: '0906.772.125',
        description: 'Specializes in cheap women\'s hair using genuine accessories. Small, cozy space, focusing on natural hair cuts, suitable for young customers.',
        imageUrl: 'https://via.placeholder.com/300x200?text=Hair+Salon+Thuy',
        latitude: 10.7727,
        longitude: 106.6956,
      ),
      Salon(
        id: 'salon_traky_004',
        name: 'Traky Hair Salon',
        location: 'Thu Duc District, Ho Chi Minh City',
        rating: 4.4,
        reviews: 127,
        priceRange: '55,000 - 180,000 VND',
        services: ['Premium Cut & Style', 'Short Hair Specialist', 'Trendy Cuts'],
        distance: 1.5,
        openHours: '9:00 AM - 8:00 PM',
        phone: '028 3715 4567',
        description: 'Small retail salon for women, famous for beautiful short haircuts and affordable prices. The stylists understand the trends, fast service, and little waiting time.',
        imageUrl: 'https://via.placeholder.com/300x200?text=Traky+Hair+Salon',
        latitude: 10.8500,
        longitude: 106.7700,
      ),
      Salon(
        id: 'salon_yoshi_005',
        name: 'Yoshi Hair Salon',
        location: 'Binh Thanh District, Ho Chi Minh City',
        rating: 4.1,
        reviews: 94,
        priceRange: '45,000 - 140,000 VND',
        services: ['Premium Cut & Style', 'Creative Styling', 'Simple Hairstyles'],
        distance: 1.8,
        openHours: '8:00 AM - 8:30 PM',
        phone: '028 3840 2255',
        description: 'Cheap salon specializing in women\'s hair cuts, good reviews for creativity and friendliness. Suitable for simple hairstyles, small but clean space.',
        imageUrl: 'https://via.placeholder.com/300x200?text=Yoshi+Hair+Salon',
        latitude: 10.8100,
        longitude: 106.7200,
      ),
      Salon(
        id: 'salon_lehieu_006',
        name: 'Le Hieu Salon',
        location: '339 Le Van Sy, District 3, Ho Chi Minh City',
        rating: 4.5,
        reviews: 241,
        priceRange: '70,000 - 220,000 VND',
        services: ['Premium Cut & Style', 'AI Color Consultation', 'Spa Treatment'],
        distance: 0.5,
        openHours: '8:30 AM - 9:00 PM',
        phone: '028 3930 7788',
        description: 'Long-standing salon with beautiful and cheap hair services, using quality products. Small scale but reputable, specializing in cutting and styling for both men and women.',
        imageUrl: 'https://via.placeholder.com/300x200?text=Le+Hieu+Salon',
        latitude: 10.7850,
        longitude: 106.6917,
      ),
    ];
  }

  static List<Salon> searchSalons({
    String? location,
    String? category,
    String? service,
    double? maxDistanceKm,
  }) {
    var salons = getHoChiMinhSalons();
    
    if (service != null && service.isNotEmpty && service != 'all') {
      salons = salons.where((salon) => 
        salon.services.any((s) => s.toLowerCase().contains(service.toLowerCase()))
      ).toList();
    }
    
    if (category != null && category.isNotEmpty && category != 'all') {
      salons = salons.where((salon) => 
        salon.services.contains(category)
      ).toList();
    }
    
    return salons;
  }
}