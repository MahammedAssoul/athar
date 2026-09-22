import '../models/charity.dart';

/// Demo charities. These are fictional organizations used for Phase 1 only.
class MockCharities {
  MockCharities._();

  static const List<Charity> all = [
    Charity(
      id: 'ch1',
      nameAr: 'جمعية الأمل الخيرية',
      nameEn: 'Al-Amal Charity',
      description:
          'جمعية خيرية تعنى بدعم الأسر المحتاجة وتوفير العلاج والغذاء للأسر المتعففة في مختلف المدن الليبية.',
      logoUrl: '',
      location: 'طرابلس',
      isVerified: true,
      campaignCount: 12,
    ),
    Charity(
      id: 'ch2',
      nameAr: 'مؤسسة الرحمة للتنمية',
      nameEn: 'Al-Rahma Development Foundation',
      description:
          'مؤسسة تنموية تركز على مشاريع المياه والتعليم وبناء المساجد في المناطق النائية.',
      logoUrl: '',
      location: 'بنغازي',
      isVerified: true,
      campaignCount: 8,
    ),
    Charity(
      id: 'ch3',
      nameAr: 'جمعية كفالة اليتيم',
      nameEn: 'Orphan Sponsorship Society',
      description:
          'جمعية متخصصة في كفالة الأيتام ورعايتهم تعليمياً وصحياً ونفسياً.',
      logoUrl: '',
      location: 'مصراتة',
      isVerified: true,
      campaignCount: 6,
    ),
    Charity(
      id: 'ch4',
      nameAr: 'جمعية العطاء الخيرية',
      nameEn: 'Al-Ataa Charity',
      description:
          'جمعية خيرية تهتم بتفريج الكربات ومساعدة الأسر المتضررة من الأزمات.',
      logoUrl: '',
      location: 'الزاوية',
      isVerified: false,
      campaignCount: 4,
    ),
    Charity(
      id: 'ch5',
      nameAr: 'مؤسسة النور الإنسانية',
      nameEn: 'Al-Noor Humanitarian Foundation',
      description:
          'مؤسسة إنسانية تعمل على توفير السكن والغذاء للعائلات المتضررة في الجنوب الليبي.',
      logoUrl: '',
      location: 'سبها',
      isVerified: true,
      campaignCount: 5,
    ),
  ];
}
